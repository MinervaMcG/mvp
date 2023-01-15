module Web3
  class WhitelistTalentMate
    def call(user:, level:)
      if user.wallet_id
        resp = client.invoke({
          function_name: ENV["WHITELIST_LAMBDA_FUNCTION"],
          invocation_type: "RequestResponse",
          log_type: "None",
          payload: JSON.generate({
            wallet_id: user.wallet_id,
            level: level
          })
        })

        response = JSON.parse(resp.payload.string)

        if response["statusCode"] == 200
          user.update!(
            whitelisted_talent_mate: true
          )
        else
          log_error(user)
          false
        end
      end
    end

    private

    def log_error(user)
      if Rails.env.production?
        Rollbar.warning("Unable to whitelist user ##{user.id}")
      else
        puts "There was an issue whitelisting user ##{user.id}"
      end
    end

    def client
      @client ||= Aws::Lambda::Client.new(region: "eu-west-2")
    end
  end
end
