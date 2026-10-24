FactoryBot.define do
  factory :chore_record do
    association :user
    association :chore
    association :chore_list_entry
    performed_on { Date.current }
    actual_minutes { 10 }
  end
end
