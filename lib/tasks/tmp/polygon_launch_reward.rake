require "web3_api/api_proxy"

namespace :talent_tokens do
  task polygon_launch_reward: :environment do
    chain_id = ENV["CONTRACTS_ENV"] == "production" ? Web3Api::ApiProxy::POLYGON_CHAIN[2].to_i : Web3Api::ApiProxy::TESTNET_POLYGON_CHAIN[2].to_i
    tokens = TalentToken.deployed.on_chain(chain_id).order("deployed_at ASC").limit(50).includes(talent: :user)
    tokens.each do |token|
      Reward.create!(user: token.talent.user, amount: 500, category: "race")
    end
  end
end
