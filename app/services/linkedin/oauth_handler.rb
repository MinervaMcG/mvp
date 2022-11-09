require "linkedin/client"

class Linkedin::OauthHandler
  class Error < StandardError; end

  class BadResponseError < Error; end

  def initialize(code:)
    @code = code
  end

  def call
    retrieve_access_token!
    retrieve_email_address!

    user = User.find_by(email: email_address)
    retrieve_lite_profile!

    user ||= create_user

    user.update!(linkedin_id: lite_profile["id"])

    upload_profile_picture(user) if lite_profile_request.success?

    {success: true, user: user}
  rescue BadResponseError => error
    Rollbar.error(error, "Unable to handle LinkedIn OAuth")
    {success: false}
  rescue => error
    Rollbar.error(
      error,
      email_address: email_address,
      display_name: display_name,
      username: username,
      linkedin_id: lite_profile["id"],
      lite_profile_request_body: lite_profile,
      email_address_request_body: email_address_request_body
    )
    {success: false}
  end

  private

  attr_reader :code

  def retrieve_access_token!
    raise BadResponseError, access_token_request.body unless access_token_request.success?
  end

  def access_token_request
    @access_token_request ||= client.retrieve_access_token(code)
  end

  def client
    @client ||= ::Linkedin::Client.new
  end

  def retrieve_email_address!
    raise BadResponseError, email_address_request.body unless email_address_request.success?
  end

  def email_address_request
    @email_address_request ||= client.retrieve_email_address(access_token)
  end

  def access_token
    @access_token ||= JSON.parse(access_token_request.body)["access_token"]
  end

  def email_address
    @email_address ||= email_address_request_body.dig("elements", 0, "handle~", "emailAddress")
  end

  def email_address_request_body
    @email_address_request_body ||= JSON.parse(email_address_request.body)
  end

  def retrieve_lite_profile!
    raise BadResponseError, lite_profile_request.body unless lite_profile_request.success?
  end

  def lite_profile_request
    @lite_profile_request ||= client.retrieve_lite_profile(access_token)
  end

  def create_user
    result = Users::Create.new.call(
      display_name: display_name,
      email: email_address,
      linkedin_id: lite_profile["id"],
      password: nil,
      username: username
    )

    raise BadResponseError, result[:error] unless result[:success]

    result[:user].tap do |user|
      user.confirm_email
      AddUsersToMailerliteJob.perform_later(user.id)
    end
  end

  def display_name
    @display_name ||=
      lite_profile.slice("localizedFirstName", "localizedLastName").values.join(" ")
  end

  def username
    Users::GenerateUsername.new(display_name: display_name).call
  end

  def lite_profile
    @lite_profile ||= JSON.parse(lite_profile_request.body)
  end

  def upload_profile_picture(user)
    talent = user.talent
    return unless talent

    return if talent.profile_picture_url

    elements = lite_profile.dig("profilePicture", "displayImage~", "elements")
    return unless elements.present?

    profile_picture_url = elements.reverse.dig(0, "identifiers", 0, "identifier")
    return unless profile_picture_url

    talent.profile_picture_attacher.context[:omniauth] = true
    talent.profile_picture = Down.open(profile_picture_url)
    talent.save!
  end

  def profile_picture_url
    elements = lite_profile.dig("profilePicture", "displayImage~", "elements")
    return unless elements.present?

    elements.reverse.dig(0, "identifiers", 0, "identifier")
  end
end
