FactoryBot.define do
  factory :erc721_token do
    address { SecureRandom.hex }
    chain_id { 137 }
    nft_type { "nft" }
  end
end
