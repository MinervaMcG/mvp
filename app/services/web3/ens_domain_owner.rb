module Web3
  class EnsDomainOwner
    def initialize(domain:)
      @domain = domain
    end

    def call
      resp = client.invoke({
        function_name: ENV["ENS_DOMAIN_OWNER_LAMBDA_FUNCTION"],
        invocation_type: "RequestResponse",
        log_type: "None",
        payload: JSON.generate({
          domain: domain,
          env: ENV["CONTRACTS_ENV"]
        })
      })

      response = JSON.parse(resp.payload.string)

      if response["statusCode"] != 200
        Rollbar.error("Unable to get owner address", domain: domain, env: ENV["CONTRACTS_ENV"], error: response["body"]["error"])
        return
      end

      response["body"]["wallet"]
    end

    private

    attr_reader :domain

    def client
      @client ||= Aws::Lambda::Client.new(region: "eu-west-2")
    end
  end
end
