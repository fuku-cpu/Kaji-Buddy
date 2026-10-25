require "rails_helper"

RSpec.describe "CharacterSettings", type: :request do
  let(:user) { create(:user) }

  describe "未ログイン時" do
    it "設定画面にアクセスするとログイン画面へリダイレクトされる" do
      get edit_character_setting_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン時" do
    before { sign_in user }

    describe "GET /character_setting/edit" do
      it "設定画面を表示できる" do
        get edit_character_setting_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "PATCH /character_setting" do
      it "キャラクターを変更でき、設定画面へリダイレクトされる" do
        patch character_setting_path, params: { user: { character_type: "coach" } }
        expect(user.reload.character_type).to eq "coach"
        expect(response).to redirect_to(edit_character_setting_path)
      end

      it "定義外の値では422が返り、変更されない" do
        patch character_setting_path, params: { user: { character_type: "invalid" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(user.reload.character_type).to eq "friend"
      end
    end
  end
end
