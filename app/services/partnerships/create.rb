module Partnerships
  class Create
    class Error < StandardError; end

    class CreationError < Error; end

    ATTRIBUTES = %w[
      button_name
      button_url
      description
      location
      name
      twitter_url
      website_url
    ].freeze

    def initialize(max_uses:, params:)
      @max_uses = max_uses
      @params = params.deep_stringify_keys
    end

    def call
      ActiveRecord::Base.transaction do
        create_partnership!
          .tap { |partnership| create_invite!(partnership) }
      end
    end

    private

    attr_reader :max_uses, :params

    def create_partnership!
      partnership = Partnership.new(params.slice(*ATTRIBUTES))

      if params["banner_url"].present?
        partnership.banner_attacher.context[:url] = true
        partnership.banner = Down.open(params["banner_url"])
      end

      if params["logo_url"].present?
        partnership.logo_attacher.context[:url] = true
        partnership.logo = Down.open(params["logo_url"])
      end

      return partnership if partnership.save

      raise CreationError, "Unable to create partnership. Errors: #{partnership.errors.full_messages.join(", ")}"
    end

    def create_invite!(partnership)
      Invites::Create.new(max_uses: max_uses, partnership: partnership, talent_invite: true).call
    end
  end
end
