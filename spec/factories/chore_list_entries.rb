FactoryBot.define do
  factory :chore_list_entry do
    association :user
    chore { association :chore, user: user }
    list_date { Date.current }
  end
end
