class ChoresController < ApplicationController
    before_action :authenticate_user!


    def index
      @categories = ChoreCategory.order(:id)
      @selected_category_id = params[:category_id].presence&.to_i

      chores = Chore.for_user(current_user).includes(:chore_category).order(:created_at)
      chores = chores.where(chore_category_id: @selected_category_id) if @selected_category_id

      @chores_by_category = chores.group_by(&:chore_category)
    end

    def new
      @chore = current_user.chores.build
    end

    def create
      @chore = current_user.chores.build(chore_params)
      if @chore.save
        redirect_to chores_path, notice: "家事を登録しました"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @chore = Chore.for_user(current_user).find(params[:id])
    end

    private

    def chore_params
      params.require(:chore).permit(:name, :chore_category_id, :estimated_minutes, :tools, :memo)
    end
end
