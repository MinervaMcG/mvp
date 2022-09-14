FactoryBot.define do
  factory :talent_token do
    association :talent
    contract_id { SecureRandom.hex }
  end
end
