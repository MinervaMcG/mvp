FactoryBot.define do
  factory :erc721_token do
    address { SecureRandom.hex }
  end
end
