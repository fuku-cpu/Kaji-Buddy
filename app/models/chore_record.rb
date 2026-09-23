class ChoreRecord < ApplicationRecord
  belongs_to :user
  belongs_to :chore
  belongs_to :chore_list_entry
end