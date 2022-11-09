FactoryBot.define do
  factory :invite do
    code { SecureRandom.hex(8) }
    max_uses { 5 }

    association :user

    factory :partnership_invite do
      user { nil }

      association :partnership
    end
  end
end
