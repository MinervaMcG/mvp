FactoryBot.define do
  factory :connection do
    connection_type { "follower" }
    connected_at { Time.now }
  end
end
