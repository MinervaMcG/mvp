module Web3
  module Tatum
    class Client
      BASE_URI = "https://api-eu1.tatum.io/v3"

      def retrieve_nfts(wallet_address:, chain:)
        url = "#{BASE_URI}/nft/address/balance/#{chain.upcase}/#{wallet_address}"

        Faraday.get(url, {}, headers)
      end

      private

      def headers
        {
          "Content-Type": "application/json",
          Accept: "application/json",
          "x-api-key": ENV["TATUM_API_KEY"]
        }
      end
    end
  end
end
