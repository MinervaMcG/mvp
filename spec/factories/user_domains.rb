FactoryBot.define do
  factory :user_domain do
    wallet { SecureRandom.hex }
    provider { "unstoppable_domains" }
    chain_id { 137 }
  end
end
