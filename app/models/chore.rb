class Chore < ApplicationRecord
    validates :name, presence: true,length:{maximum: 255}
    validates :estimated_minutes, presence: true,length:{maximum: 24}

    belongs_to :user, optional: true
    belongs_to :chore_category

    scope :common, -> { where(user_id: nil) }
    scope :for_user, ->(user) {where(user_id: [nil, user.id]) }

    def owned_by?(user)
      user_id == user.id
    end

    def common?
      user_id.nil?
    end
end
