class StaticPagesController < ApplicationController
  def top
    @chore_list_entries = ChoreListEntry
      .for_user(current_user)
      .for_date(Date.current)
      .includes(:chore, :chore_record)
      .order(:id)
  end
end
