FactoryBot.define do
  factory :chore do
    association :user
    association :chore_category
    sequence(:name) { |n| "家事#{n}" }
    estimated_minutes { 15 }

    trait :master do
      user { nil }
    end
  end
end
