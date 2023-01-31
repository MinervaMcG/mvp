require "the_graph/celo/client"
require "the_graph/mumbai/client"
require "the_graph/alfajores/client"
require "the_graph/polygon/client"

module Talents
  class MigrateSupporters
    def initialize(old_contract_id:, old_chain_id:, talent_token_id:)
      @old_contract_id = old_contract_id
      @old_chain_id = old_chain_id
      @talent_token_id = talent_token_id
    end

    def call
      supporters = talent_supporters.talent_token&.supporters || []
      unless supporters.empty?
        supporter_addresses = supporters.map { |s| s.supporter.id }
        supporter_amounts = supporters.map { |s| s.amount.to_i }

        tx_hash = eth_client.transact(staking_contract, "migrateStakes", talent_token.contract_id, supporter_addresses, supporter_amounts, sender_key: Eth::Key.new(priv: ENV["CELO_WALLET_PRIVATE_KEY"]))
        tx_hash = eth_client.wait_for_tx(tx_hash)

        if eth_client.tx_succeeded?(tx_hash)
          TalentSupporter.where(talent_contract_id: old_contract_id).destroy_all!
          Connection.where(user_id: talent_token.talent.user_id).destroy_all!
        end
      end
    end

    private

    attr_accessor :old_chain_id, :talent_token_id, :old_contract_id

    def talent_token
      @talent_token ||= TalentToken.find(talent_token_id)
    end

    def talent_supporters
      the_graph_client.talent_supporters(
        talent_address: old_contract_id,
        variance_start_date: (Time.now.utc - 30.days).to_i
      )
    end

    def the_graph_client
      @the_graph_client ||=
        "TheGraph::#{TheGraphAPI::CHAIN_TO_NAME[old_chain_id]}::Client".constantize.new
    end

    def eth_client
      @eth_client ||= "EthClient::#{EthClient::CHAIN_TO_NAME[talent_token.chain_id]}::Client".constantize
    end

    def contract_abi
      JSON.parse(File.read(Rails.root.join("app/packs/src/abis/recent/Staking.json")))["abi"]
    end

    def staking_contract
      @staking_contract ||= Eth::Contract.from_abi(abi: contract_abi, address: EthClient::CHAIN_TO_STAKING_ADDRESS[talent_token.chain_id], name: "Staking")
    end
  end
end
