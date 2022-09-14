module Talents
  class SendTokenNotificationToDiscord
    include Rails.application.routes.url_helpers

    def initialize
      @url = ENV["DISCORD_WEBHOOK_URL"]
    end

    def call(talent_token_id)
      talent_toke = TalentToken.find(talent_token_id)
      talent = talent_toke.talent
      user = talent.user

      message = "_#{user.username}_ is a _#{talent.profile[:occupation]}_ and just launched their Talent Token **$#{talent_toke.ticker}**. Take a look at their profile and become part of their career journey: #{user_url(talent)}"
      post(message)
    end

    private

    def post(message)
      Faraday.post(
        @url.to_s,
        {
          content: message
        }.to_json,
        {
          "Content-Type": "application/json"
        }
      )
    end
  end
end
