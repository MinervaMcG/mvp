FactoryBot.define do
  factory :erc20_token do
    address { SecureRandom.hex }
    chain_id { 137 }
  end
end
