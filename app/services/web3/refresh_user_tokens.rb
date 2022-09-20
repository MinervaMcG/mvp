require "web3/api_proxy"

module Web3
  class RefreshUserTokens
    class Error < StandardError; end

    class InvalidScopeError < Error; end

    class UNknownChainIdError < Error; end

    VALID_SCOPES = %w[all tokens nfts poaps]

    def initialize(user:, scope: "all", chain: "all")
      raise InvalidScopeError.new("#{scope} is not a valid. Valid options are: #{VALID_SCOPES.join(", ")}") unless VALID_SCOPES.include?(scope)

      @user = user
      @scope = scope
      @chain = chain
    end

    def call
      case scope
      when "all"
        refresh_tokens
        refresh_nfts
        refresh_poaps
      when "tokens"
        refresh_tokens
      when "nfts"
        refresh_nfts
      when "poaps"
        refresh_poaps
      end
    end

    private

    attr_reader :user, :scope, :chain

    def refresh_tokens
      tokens_by_chain = {}
      if chain == "all"
        all_chains.each do |supported_chain|
          chain_id = chain_id_from(supported_chain)
          tokens_by_chain[chain_id] = web3_proxy.retrieve_tokens(wallet_address: wallet_address, chain: supported_chain)
        end
      else
        chain_id = chain_id_from(chain)
        tokens_by_chain[chain_id] = web3_proxy.retrieve_tokens(wallet_address: wallet_address, chain: chain)
      end

      tokens_by_chain.each do |chain_id, tokens|
        tokens.each do |token_data|
          upsert_erc20_token(token_data, chain_id)
        end
      end
    end

    def upsert_erc20_token(token_data, chain_id)
      token = Erc20Token.find_or_create_by!(address: token_data[:address], user: user, chain_id: chain_id)

      token.update!(
        name: token_data[:name],
        symbol: token_data[:symbol],
        logo: token_data[:logo],
        thumbnail: token_data[:thumbnail],
        decimals: token_data[:decimals],
        balance: token_data[:balance],
        last_sync_at: current_time
      )
    end

    def refresh_nfts
      nfts_by_chain = {}
      if chain == "all"
        all_chains.each do |supported_chain|
          chain_id = chain_id_from(supported_chain)
          nfts_by_chain[chain_id] = web3_proxy.retrieve_nfts(wallet_address: wallet_address, chain: supported_chain)
        end
      else
        chain_id = chain_id_from(chain)
        nfts_by_chain[chain_id] = web3_proxy.retrieve_nfts(wallet_address: wallet_address, chain: chain)
      end

      nfts_by_chain.each do |chain_id, tokens|
        tokens.each do |token_data|
          upsert_erc721_token(token_data, chain_id, "nft")
        end
      end
    end

    def refresh_poaps
      poaps = web3_proxy.retrieve_poaps(wallet_address: wallet_address)

      poaps.each do |token|
        upsert_erc721_token(token, Web3::ApiProxy::GNOSIS_CHAIN_ID, "poap")
      end
    end

    def chain_id_from(chain)
      formatted_chain = chain.to_s.downcase

      return 1 if Web3::ApiProxy::ETH_CHAIN.include?(formatted_chain)
      return 89 if Web3::ApiProxy::POLYGON_CHAIN.include?(formatted_chain)
      return 44787 if Web3::ApiProxy::CELO_CHAIN.include?(formatted_chain)

      raise UNknownChainIdError.new
    end

    def upsert_erc721_token(token_data, chain_id, type)
      token = Erc721Token.find_or_create_by!(address: token_data[:address], user: user, nft_type: type, chain_id: chain_id)
      token.update!(
        name: token_data[:name],
        symbol: token_data[:symbol],
        token_id: token_data[:token_id],
        url: token_data[:token_uri],
        metadata: token_data[:metadata],
        last_sync_at: current_time
      )
    end

    def wallet_address
      @wallet_address ||= user.wallet_id
    end

    def all_chains
      Web3::ApiProxy::SUPPORTED_CHAIN_NAMES
    end

    def web3_proxy
      @web3_proxy ||= Web3::ApiProxy.new
    end

    def current_time
      @current_time ||= Time.zone.now
    end
  end
end
