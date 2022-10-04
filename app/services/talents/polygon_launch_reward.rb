require "web3/api_proxy"

module Talents
  class PolygonLaunchReward
    def initialize
      @contract_env = ENV["CONTRACTS_ENV"]
      @chain_id = chain_id
    end

    def call(user)
      polygon_tokens_count = TalentToken.deployed.on_chain(@chain_id).count
      Reward.create!(user: user, amount: 500, category: "race") if polygon_tokens_count <= 50
    end

    private

    def chain_id
      network = Web3::ApiProxy.const_get("#{@contract_env == "production" ? "" : "TESTNET"}_POLYGON_CHAIN")
      network[2].to_i
    end
  end
end
