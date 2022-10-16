module Web3Api
  module GnosisChainExplorer
    class Client
      BASE_URI = "https://blockscout.com/xdai/mainnet/api"

      def retrieve_tokens(wallet_address:)
        params = {
          module: "account",
          action: "tokentx",
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
