FactoryBot.define do
  factory :talent do
    public { true }

    trait :with_token do
      association :talent_token
    end

    trait :with_career_goal do
      association :career_goal
    end

    trait :full_profile do
      association :talent_token
      association :career_goal
    end
  end
end
