FactoryBot.define do
  factory :user do
    sequence :username do |n|
      "user#{n}"
    end
    sequence :email do |n|
      "user_#{n}@talentprotocol.com"
    end
    password { "password" }
    email_confirmed_at { Time.current }
    wallet_id { SecureRandom.hex }
    onboarded_at { Time.current }

    trait :with_talent do
      association :talent
    end

    trait :full_profile do
      association :talent, :full_profile
    end

    trait :with_profile_complete do
      after(:create) { |user| create(:quest, user: user, type: "Quests::TalentProfile", status: "done") }
    end
  end
end
