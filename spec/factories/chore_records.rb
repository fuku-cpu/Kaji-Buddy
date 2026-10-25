FactoryBot.define do
  factory :chore_record do
    association :user
    chore { association :chore, user: user }
    chore_list_entry { association :chore_list_entry, user: user, chore: chore }
    performed_on { Date.current }
    actual_minutes { 10 }
  end
end