class ChoreRecord < ApplicationRecord
  belongs_to :user
  belongs_to :chore
  belongs_to :chore_list_entry

  # 保存前に、実施時間が空なら目安時間をいれる
  before_validation :set_default_actual_minutes

  validates :performed_on, presence: true
  validates :actual_minutes, presence: true,
                           numericality: { only_integer: true, greater_than: 0 }
  validates :chore_list_entry_id, uniqueness: true

  # 期間で絞りこむ
  scope :performed_within, ->(range) { where(performed_on: range) }
  # 新しい順に並べる
  scope :recent_first, -> { order(performed_on: :desc, created_at: :desc) }

  # 目安よりも早く終わった分数 (早くなければ nil)
  def minutes_saved
    diff = chore.estimated_minutes - actual_minutes
    diff.positive? ? diff : nil
  end

  private

  def set_default_actual_minutes
    self.actual_minutes ||= chore&.estimated_minutes
  end
end