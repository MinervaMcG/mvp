FactoryBot.define do
  factory :goal do
    sequence :title do |n|
      "Title #{n}"
    end

    association :career_goal
  end
end
