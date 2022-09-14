FactoryBot.define do
  factory :erc20_token do
    address { SecureRandom.hex }
  end
end
