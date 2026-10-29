class ChoreListEntriesController < ApplicationController
  before_action :authenticate_user!

  def guide; end

  def index
    @today = Date.current
    @chore_list_entries = ChoreListEntry.daily_list_for(current_user, @today).order(:id)
    @summary = DailyChoreSummary.new(@chore_list_entries, date: @today)
  end

  def new
    @chores_by_category = Chore.for_user(current_user)
                              .includes(:chore_category)
                              .order(:chore_category_id, :name)
                              .group_by(&:chore_category)

    today_entries = ChoreListEntry.for_user(current_user).for_date(Date.current)
    @added_chore_ids = today_entries.pluck(:chore_id)
    @today_total_minutes = today_entries.joins(:chore).sum("chores.estimated_minutes")
  end

  def create
    chores = Chore.for_user(current_user).where(id: Array(params[:chore_ids]).compact_blank)
    return redirect_to new_chore_list_entry_path, alert: "追加する家事を選択してください" if chores.empty?

    ChoreListEntry.bulk_add!(user: current_user, chores: chores, date: Date.current)
    redirect_to root_path, notice: "#{chores.size}件の家事を今日のリストに追加しました"
  end

  def destroy
    entry = current_user.chore_list_entries.find(params[:id])
    if entry.destroy
      redirect_to chore_list_entries_path, notice: "「#{entry.name}」をリストから外しました", status: :see_other
    else
      redirect_to chore_list_entries_path, alert: "完了済みの家事は外せません", status: :see_other
    end
  end
end
