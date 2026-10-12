class CharacterSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def edit; end

  def update
    if @user.update(character_params)
      redirect_to edit_character_setting_path, notice: "応援キャラクターを変更しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def character_params
    params.expect(user: [:character_type])
  end
end
