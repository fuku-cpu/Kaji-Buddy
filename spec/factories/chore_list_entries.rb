FactoryBot.define do
  factory :chore_list_entry do
    association :user
    association :chore
    list_date { Date.current }
  end
end
