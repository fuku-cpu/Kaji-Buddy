class Chore < ApplicationRecord
    validates :name, presence: true,length:{maximum: 255}
    validates :estimated_minutes, presence: true,length:{maximum: 24}

    belongs_to :user
    belongs_to :chore_category
end
