FactoryBot.define do
  factory :user do
    sequence :username do |n|
      "user#{n}"
    end
    sequence :email do |n|
      "user_#{n}@talentprotocol.com"
    end
    password { "password" }
    email_confirmed_at { Date.today }
    wallet_id { SecureRandom.hex }
    onboarding_complete { true }

    trait :with_talent do
      association :talent
    end

    trait :full_profile do
      association :talent, :full_profile
    end
  end
end
