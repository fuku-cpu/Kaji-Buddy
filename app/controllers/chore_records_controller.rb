class ChoreRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    @period = Date.current.all_week
    records = current_user.chore_records.performed_within(@period)

    @total_minutes = records.sum(:actual_minutes)
    @records_by_date = records.includes(chore: :chore_category)
                              .recent_first
                              .group_by(&:performed_on)
  end

  def create
    @entry = ChoreListEntry.for_user(current_user).find(params[:chore_list_entry_id])
    return head :unprocessable_content if @entry.completed?

    @record = @entry.build_record(actual_minutes: params[:actual_minutes])
    return render :error, status: :unprocessable_content unless @record.save

    @feedback = FeedbackMessage.new(@record)
    set_today_summary
  end

  def destroy
    @record = current_user.chore_records.find(params[:id])
    @entry = @record.chore_list_entry
    @record.destroy!

    set_today_summary
  end

  private

  def set_today_summary
    today = Date.current
    entries = ChoreListEntry.daily_list_for(current_user, today)
    @summary = DailyChoreSummary.new(entries, date: today)
  end
end
