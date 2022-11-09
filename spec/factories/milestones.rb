FactoryBot.define do
  factory :milestone do
    association :talent
    title { "Title" }
    start_date { Time.zone.today }
    end_date { Time.zone.today + 10.days }
  end
end
