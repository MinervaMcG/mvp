FactoryBot.define do
  factory :milestone do
    sequence :title do |n|
      "Title #{n}"
    end
    start_date { Time.zone.today }
    end_date { Time.zone.today + 10.days }

    association :talent
  end
end
