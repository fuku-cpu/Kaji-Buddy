class ChoreListEntry < ApplicationRecord
  belongs_to :user
  belongs_to :chore
  has_one :chore_record, dependent: :restrict_with_error

  validates :list_date, presence: true
  validates :chore_id, uniqueness: { scope: %i[user_id list_date] }

  scope :for_user, ->(user) { where(user: user) }
  scope :for_date, ->(date) { where(list_date: date) }

  delegate :name, :estimated_minutes, to: :chore

  def completed?
    chore_record.present?
  end
end