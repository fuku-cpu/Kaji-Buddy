class ChoreListEntry < ApplicationRecord
  belongs_to :user
  belongs_to :chore
  has_one :chore_record, dependent: :restrict_with_error

  validates :list_date, presence: true
  validates :chore_id, uniqueness: { scope: %i[user_id list_date] }

  scope :for_user, ->(user) { where(user: user) }
  scope :for_date, ->(date) { where(list_date: date) }
  scope :daily_list_for, ->(user, date) { for_user(user).for_date(date).includes(:chore, :chore_record) }

  delegate :name, :estimated_minutes, to: :chore

  # 選択された家事をまとめて指定日のリストに追加する（既に追加済みのものはスキップ）
  def self.bulk_add!(user:, chores:, date:)
    transaction do
      chores.each do |chore|
        user.chore_list_entries.find_or_create_by!(chore: chore, list_date: date)
      end
    end
  end

  def completed?
    chore_record.present?
  end

  # このエントリーを完了させる記録を組み立てる（保存はControllerで行う）
  def build_record(actual_minutes:)
    build_chore_record(
      user: user,
      chore: chore,
      performed_on: Date.current,
      actual_minutes: actual_minutes
    )
  end
end
