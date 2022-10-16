require "web3/api_proxy"

module Talents
  class PolygonLaunchReward
    def call(user)
      polygon_tokens_count = TalentToken.deployed.on_chain(chain_id).count
      Reward.create!(user: user, amount: 500, category: "race") if polygon_tokens_count <= 50
    end

    private

    def chain_id
      network = Web3::ApiProxy.const_get("#{ENV["CONTRACTS_ENV"] == "production" ? "" : "TESTNET_"}POLYGON_CHAIN")
      network[2].to_i
    end
  end
end
