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
      p talent_supporters
    end

    private

    attr_accessor :old_chain_id, :talent_token_id, :old_contract_id

    def talent_supporters
      the_graph_client.talent_supporters(
        talent_address: old_contract_id
      )
    end

    def the_graph_client
      @the_graph_client ||=
        "TheGraph::#{TheGraphAPI::CHAIN_TO_NAME[old_chain_id]}::Client".constantize.new
    end
  end
end
