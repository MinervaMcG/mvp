require "web3_api/celo_explorer/client"
require "web3_api/gnosis_chain_explorer/client"
require "web3_api/moralis/client"
require "web3_api/tatum/client"

module Web3Api
  class ApiProxy
    class Error < StandardError; end

    class UnsupportedChainError < Error; end

    class ApiClientRequestError < Error; end

    SUPPORTED_CHAIN_IDS = %w[0x1 0xa4ec 0x89]
    SUPPORTED_CHAIN_NAMES = %w[celo eth polygon]

    CELO_CHAIN = %w[celo 0xa4ec 42220]
    ETH_CHAIN = %w[eth 0x1 1]
    POLYGON_CHAIN = %w[polygon 0x89 137]

    TESTNET_CELO_CHAIN = %w[celo 0xaef3 44787]
    TESTNET_ETH_CHAIN = %w[eth 0x3 3]
    TESTNET_POLYGON_CHAIN = %w[polygon 0x1f41 80001]

    GNOSIS_CHAIN_ID = 100

    SUPPORTED_CHAINS = SUPPORTED_CHAIN_IDS + SUPPORTED_CHAIN_NAMES

    def retrieve_tokens(wallet_address:, chain: nil)
      validate_chain!(chain)

      formatted_chain = formatted_chain(chain)

      return celo_explorer_tokens(wallet_address) if celo?(formatted_chain)

      moralis_tokens(wallet_address, formatted_chain)
    end

    def retrieve_nfts(wallet_address:, chain: nil)
      validate_chain!(chain)

      formatted_chain = formatted_chain(chain)

      return tatum_nfts(wallet_address, "CELO") if celo?(formatted_chain)

      moralis_nfts(wallet_address, formatted_chain)
    end

    def retrieve_poaps(wallet_address:)
      gnosis_poaps(wallet_address)
    end

    private

    def validate_chain!(chain)
      formatted_chain = formatted_chain(chain)

      raise UnsupportedChainError.new("Invalid chain: #{chain}/#{formatted_chain}, valid chains: #{SUPPORTED_CHAINS.join(", ")}") unless SUPPORTED_CHAINS.include?(formatted_chain)
    end

    def celo?(chain)
      CELO_CHAIN.include?(formatted_chain(chain))
    end

    def formatted_chain(chain)
      chain.is_a?(Integer) ? "0x#{chain.to_s(16).downcase}" : chain.downcase
    end

    def celo_explorer_tokens(wallet_address)
      response = celo_explorer_tokens_response(wallet_address)
      validate_response!(response)

      response_body = JSON.parse(response.body)

      tokens = response_body["result"].map do |item|
        if item["type"] == "ERC-20"
          {
            address: item["contractAddress"],
            name: item["name"],
            symbol: item["symbol"],
            logo: nil,
            thumbnail: nil,
            decimals: item["decimals"],
            balance: item["balance"]
          }
        end
      end

      tokens.compact
    end

    def moralis_tokens(wallet_address, chain)
      response = moralis_tokens_response(wallet_address, chain)
      validate_response!(response)

      response_body = JSON.parse(response.body)

      response_body.map do |item|
        {
          address: item["token_address"],
          name: item["name"],
          symbol: item["symbol"],
          logo: item["logo"],
          thumbnail: item["thumbnail"],
          decimals: item["decimals"],
          balance: item["balance"]
        }
      end
    end

    def celo_explorer_nfts(wallet_address)
      response = celo_explorer_tokens_response(wallet_address)
      validate_response!(response)

      response_body = JSON.parse(response.body)

      tokens = response_body["result"].map do |item|
        if item["type"] == "ERC-721"
          {
            address: item["contractAddress"],
            token_id: nil,
            amount: item["balance"],
            name: item["name"],
            symbol: item["symbol"],
            token_uri: nil,
            metadata: nil
          }
        end
      end

      tokens.compact
    end

    def moralis_nfts(wallet_address, chain)
      response = moralis_nfts_response(wallet_address, chain)
      validate_response!(response)

      response_body = JSON.parse(response.body)

      tokens = response_body["result"].map do |item|
        {
          address: item["token_address"],
          token_id: item["token_id"],
          amount: item["amount"],
          name: item["name"],
          symbol: item["symbol"],
          token_uri: item["token_uri"]&.start_with?("http") ? item["token_uri"] : nil,
          metadata: item["metadata"].present? ? JSON.parse(item["metadata"]) : nil
        }
      end

      tokens.compact
    end

    def tatum_nfts(wallet_address, chain)
      response = tatum_nfts_response(wallet_address, chain)
      validate_response!(response)

      response_body = JSON.parse(response.body)

      tokens = response_body.map do |item|
        item["metadata"].map do |token_metadata|
          {
            address: item["contractAddress"],
            token_id: token_metadata["tokenId"],
            amount: 1,
            name: token_metadata["metadata"].present? ? token_metadata["metadata"]["name"] : nil,
            symbol: token_metadata["metadata"].present? ? token_metadata["metadata"]["name"] : nil,
            token_uri: token_metadata["url"].start_with?("http") ? token_metadata["url"] : nil,
            metadata: token_metadata["metadata"].present? ? token_metadata["metadata"] : nil
          }
        end
      end

      tokens.flatten.compact
    end

    def gnosis_poaps(wallet_address)
      response = gnosis_chain_explorer_client.retrieve_tokens(wallet_address: wallet_address)
      validate_response!(response)

      response_body = JSON.parse(response.body)

      token_ids_and_contract_address = response_body["result"].map do |result|
        next if result["tokenName"] != "POAP"

        {token_id: result["tokenID"], address: result["contractAddress"]}
      end

      token_ids_and_contract_address.compact
    end

    def celo_explorer_tokens_response(wallet_address)
      celo_explorer_api_client.retrieve_tokens(wallet_address: wallet_address)
    end

    def moralis_tokens_response(wallet_address, chain)
      moralis_api_client.retrieve_tokens(wallet_address: wallet_address, chain: chain)
    end

    def moralis_nfts_response(wallet_address, chain)
      moralis_api_client.retrieve_nfts(wallet_address: wallet_address, chain: chain)
    end

    def tatum_nfts_response(wallet_address, chain)
      @tatum_nfts_response ||= tatum_api_client.retrieve_nfts(wallet_address: wallet_address, chain: chain)
    end

    def validate_response!(response)
      raise ApiClientRequestError.new(response.body) unless response.success?
    end

    def moralis_api_client
      @moralis_api_client ||= Moralis::Client.new
    end

    def celo_explorer_api_client
      @celo_explorer_api_client ||= CeloExplorer::Client.new
    end

    def tatum_api_client
      @tatum_api_client ||= Tatum::Client.new
    end

    def gnosis_chain_explorer_client
      @gnosis_chain_explorer_client ||= GnosisChainExplorer::Client.new
    end
  end
end
