module Web3Api
  module CeloExplorer
    class Client
      BASE_URI = "https://explorer.celo.org/api"

      def retrieve_tokens(wallet_address:)
        params = {
          module: "account",
          action: "tokenlist",
          address: wallet_address
        }
        Faraday.get(BASE_URI, params, headers)
      end

      private

      def headers
        {
          "Content-Type": "application/json",
          Accept: "application/json"
        }
      end
    end
  end
end
