module UnstoppableDomains
  class LoginUser
    class Error < StandardError; end

    class WalletVerificationError < Error; end

    class UserCreationError < Error; end

    def initialize(params)
      @params = params
    end

    def call
      verify_wallet!

      ActiveRecord::Base.transaction do
        user = upsert_user!

        upsert_profile_picture(user)
        upsert_talent_data(user)
        refresh_domains(user)

        user
      end
    end

    private

    attr_reader :params

    def verify_wallet!
      verified_wallet = Web3::VerifyWallet.new(
        params[:wallet_address],
        params[:eip4361_signature],
        params[:eip4361_message]
      ).call

      unless verified_wallet
        raise WalletVerificationError, "Wallet signatures are not matching. Try again."
      end
    end

    def upsert_user!
      user = User.find_by(wallet_id: params[:wallet_address])
      user ||= User.find_by(email: params[:email])
      return user if user

      result = Users::Create.new.call(
        legal_first_name: legal_first_name,
        legal_last_name: legal_last_name,
        display_name: params[:name],
        wallet_id: params[:wallet_address],
        email: params[:email],
        password: SecureRandom.hex,
        username: username
      )

      raise UserCreationError, result[:error] unless result[:success]

      result[:user].tap do |user|
        user.confirm_email
        AddUsersToMailerliteJob.perform_later(user.id)
      end
    end

    def username
      Users::GenerateUsername.new(display_name: params[:name]).call
    end

    def upsert_profile_picture(user)
      talent = user.talent
      return if talent.profile_picture_url
      picture = params[:picture]
      return unless picture.present?

      talent.profile_picture_attacher.context[:omniauth] = true
      talent.profile_picture = Down.open(picture)
      talent.save!
    end

    def upsert_talent_data(user)
      talent = user.talent
      talent.twitter = twitter_url if talent.twitter.blank?
      talent.website = ipfs_website if talent.website.blank?
      talent.save!
    end

    def twitter_url
      return unless params[:twitter] && params[:twitter][:location]

      params[:twitter][:location]
    end

    def ipfs_website
      return unless params[:ipfs_website]

      "https://ipfs.io/ipfs/#{params[:ipfs_website]}"
    end

    def legal_first_name
      return unless params[:name] && params[:name].split(" ")[0]

      params[:name].split(" ")[0]
    end

    def legal_last_name
      return unless params[:name] && params[:name].split(" ")[-1]

      params[:name].split(" ")[-1]
    end

    def refresh_domains(user)
      Web3::RefreshDomains.new(user: user).call
    end
  end
end
