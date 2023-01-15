require "unstoppable_domains/client"

module Web3
  class RefreshDomains
    class Error < StandardError; end

    class WalletNotDefinedError < Error; end

    def initialize(user:)
      raise WalletNotDefinedError.new("Wallet not defined for user: #{user.id}") unless user.wallet_id.present?

      @user = user
    end

    def call
      return unless domain_data["domain"].present?

      UserDomain.find_or_create_by!(
        user: user,
        domain: domain_data["domain"],
        chain_id: domain_data["networkId"],
        wallet: user.wallet_id,
        provider: "unstoppable_domains"
      )
    end

    private

    attr_reader :user

    def domain_data
      @domain_data ||= unstoppable_domains_response_body["meta"]
    end

    def unstoppable_domains_response_body
      @unstoppable_domains_response_body ||= JSON.parse(unstoppable_domains_response.body)
    end

    def unstoppable_domains_response
      @unstoppable_domains_response ||= client.get_address_domains(address: user.wallet_id)
    end

    def client
      UnstoppableDomains::Client.new
    end
  end
end
