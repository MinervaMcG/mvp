module Web3Api
  module Moralis
    class Client
      BASE_URI = "https://deep-index.moralis.io/api/v2"
      TOKENS_URI_PATH = "erc20"
      NFTS_URI_PATH = "nft"

      def retrieve_tokens(wallet_address:, chain:)
        url = "#{BASE_URI}/#{wallet_address}/#{TOKENS_URI_PATH}"

        params = {
          chain: chain
        }
        Faraday.get(url, params, headers)
      end

      def retrieve_wallet_nfts(wallet_address:, chain:)
        url = "#{BASE_URI}/#{wallet_address}/#{NFTS_URI_PATH}"

        params = {
          chain: chain
        }
        Faraday.get(url, params, headers)
      end

      def retrieve_contract_nfts(contract_address:, chain:)
        url = "#{BASE_URI}/#{NFTS_URI_PATH}/#{contract_address}"

        params = {
          chain: chain,
          format: "decimal"
        }
        Faraday.get(url, params, headers)
      end

      def retrieve_transactions(address:, start_timestamp:, chain:)
        url = "#{BASE_URI}/#{address}"

        params = {
          chain: chain,
          from_date: start_timestamp
        }
        Faraday.get(url, params, headers)
      end

      private

      def headers
        {
          "Content-Type": "application/json; charset=utf-8",
          "x-api-key": ENV["MORALIS_API_KEY"]
        }
      end
    end
  end
end
