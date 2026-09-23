class ChoreRecordsController < ApplicationController
  def create
    entry = ChoreListEntry.for_user(current_user).find(params[:chore_list_entry_id])
    @record = entry.build_chore_record(
      user: current_user,
      chore: entry.chore,
      performed_on: Date.current,
      actual_minutes: params[:actual_minutes]
    )
    @record.save!
    @entry = entry
  end

  def destroy
    @record = current_user.chore_records.find(params[:id])
    @entry = @record.chore_list_entry
    @record.destroy!
  end
end