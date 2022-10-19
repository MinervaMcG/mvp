module Web3Api
  module CeloExplorer
    class Client
      def retrieve_tokens(wallet_address:)
        params = {
          module: "account",
          action: "tokenlist",
          address: wallet_address
        }
        Faraday.get(ENV["CELO_EXPLORER_BASE_URI"], params, headers)
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
