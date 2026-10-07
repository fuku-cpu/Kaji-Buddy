class ChoreRecordsController < ApplicationController
  def index
    @period = Date.current.all_week
    records = current_user.chore_records.performed_within(@period)

    @total_minutes = records.sum(:actual_minutes)
    @records_by_date = records.includes(chore: :chore_category)
                              .recent_first
                              .group_by(&:performed_on)
  end

  def create
    entry = ChoreListEntry.for_user(current_user).find(params[:chore_list_entry_id])

    return head :unprocessable_content if entry.chore_record.present?

    @record = entry.build_chore_record(
      user: current_user,
      chore: entry.chore,
      performed_on: Date.current,
      actual_minutes: params[:actual_minutes]
    )
    
    @entry = entry

    head :unprocessable_content unless @record.save
  end

  def destroy
    @record = current_user.chore_records.find(params[:id])
    @entry = @record.chore_list_entry
    @record.destroy!
  end
end