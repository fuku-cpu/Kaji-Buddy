class FeedbackMessage
  attr_reader :chore_record

  def initialize(chore_record)
    @chore_record = chore_record
    @user = chore_record.user
  end

  # キャラ選択画面の見本用
  def self.sample_for(character)
    I18n.t("feedback_messages.#{character}.default", raise: true).first
  end

  def text
    @text ||= format(templates.sample, count: today_count, minutes: saved_minutes)
  end

  def character
    @user.character_type.to_sym
  end

  def situation
    @situation ||=
      if all_completed?
        :all_completed
      elsif faster?
        :faster
      elsif today_count >= 2
        :nth
      else
        :default
      end
  end

  private

  # 文言は config/locales/feedback_messages.ja.yml で管理
  def templates
    I18n.t("feedback_messages.#{character}.#{situation}", raise: true)
  end

  # その日のリストに「記録が無いエントリー」が1件も残っていない
  def all_completed?
    ChoreListEntry.for_user(@user)
                  .for_date(chore_record.performed_on)
                  .where.missing(:chore_record)
                  .none?
  end

  def faster?
    saved_minutes.positive?
  end

  def saved_minutes
    chore_record.chore.estimated_minutes - chore_record.actual_minutes
  end

  def today_count
    @today_count ||= ChoreRecord.where(user: @user, performed_on: chore_record.performed_on).count
  end
end
