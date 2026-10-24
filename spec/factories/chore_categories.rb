FactoryBot.define do
  factory :chore_category do
    sequence(:name) { |n| "カテゴリ#{n}" }
  end
end
