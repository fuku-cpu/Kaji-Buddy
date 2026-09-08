class ChoresController < ApplicationController
    before_action :authenticate_user!


    def index
      @categories = ChoreCategory.order(:id)
      @selected_category_id = params[:category_id].presence&.to_i

      chores = Chore.for_user(current_user).includes(:chore_category).order(:created_at)
      chores = chores.where(chore_category_id: @selected_category_id) if @selected_category_id

      @chores_by_category = chores.group_by(&:chore_category)
    end
end
