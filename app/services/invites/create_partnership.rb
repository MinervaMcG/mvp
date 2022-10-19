module Invites
  class CreatePartnership
    class Error < StandardError; end

    class CreationError < Error; end

    class InviteAlreadyExistsError < Error; end

    ATTRIBUTES = %w[
      button_name
      button_url
      description
      location
      name
      twitter_url
      website_url
    ].freeze

    def initialize(user:, invite_code:, max_uses:, partnership_params:)
      @user = user
      @invite_code = invite_code
      @max_uses = max_uses
      @partnership_params = partnership_params.stringify_keys
    end

    def call
      validate!

      ActiveRecord::Base.transaction do
        invite = create_invite!
        create_partnership!(invite)
      end
    end

    private

    attr_reader :user, :invite_code, :max_uses, :partnership_params

    def validate!
      raise InviteAlreadyExistsError, "Talent invite already created for the user." if user.invites.find_by(talent_invite: true)
    end

    def create_invite!
      invite = Invite.new(code: invite_code, max_uses: max_uses, talent_invite: true, user: user)
      raise CreationError, "Unable to create invite. Errors: #{invite.errors.full_messages.join(", ")}" unless invite.save

      invite
    end

    def create_partnership!(invite)
      partnership = Partnership.new(partnership_params.slice(*ATTRIBUTES).merge(invite: invite))

      if partnership_params["banner_url"].present?
        partnership.banner_attacher.context[:url] = true
        partnership.banner = Down.open(partnership_params["banner_url"])
      end

      if partnership_params["logo_url"].present?
        partnership.logo_attacher.context[:url] = true
        partnership.logo = Down.open(partnership_params["logo_url"])
      end

      raise CreationError, "Unable to create partnership. Errors: #{partnership.errors.full_messages.join(", ")}" unless partnership.save

      partnership
    end
  end
end
