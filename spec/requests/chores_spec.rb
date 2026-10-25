require "rails_helper"

RSpec.describe "Chores", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:category) { create(:chore_category) }
  let(:valid_params) { { chore: { name: "洗濯", estimated_minutes: 30, chore_category_id: category.id } } }

  describe "未ログイン時" do
    it "一覧にアクセスするとログイン画面へリダイレクトされる" do
      get chores_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "家事を作成できない" do
      expect { post chores_path, params: valid_params }.not_to change(Chore, :count)
    end
  end

  describe "ログイン時" do
    before { sign_in user }

    describe "GET /chores" do
      it "自分の家事と共通の家事が表示され、他人の家事は表示されない" do
        create(:chore, user: user, name: "自分の家事")
        create(:chore, :master, name: "共通の家事")
        create(:chore, user: other_user, name: "他人の家事")

        get chores_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("自分の家事", "共通の家事")
        expect(response.body).not_to include("他人の家事")
      end

      it "カテゴリで絞り込める" do
        create(:chore, user: user, chore_category: category, name: "洗濯")
        create(:chore, user: user, chore_category: create(:chore_category), name: "皿洗い")

        get chores_path, params: { category_id: category.id }
        expect(response.body).to include("洗濯")
        expect(response.body).not_to include("皿洗い")
      end
    end

    describe "GET /chores/:id" do
      it "自分の家事は表示できる" do
        get chore_path(create(:chore, user: user))
        expect(response).to have_http_status(:ok)
      end

      it "共通の家事は表示できる" do
        get chore_path(create(:chore, :master))
        expect(response).to have_http_status(:ok)
      end

      it "他人の家事は404になる" do
        get chore_path(create(:chore, user: other_user))
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "GET /chores/new" do
      it "登録画面を表示できる" do
        get new_chore_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /chores" do
      it "ログインユーザーの家事として作成され、一覧へリダイレクトされる" do
        expect { post chores_path, params: valid_params }.to change(user.chores, :count).by(1)
        expect(response).to redirect_to(chores_path)
      end

      it "user_idを送っても他人の家事としては作成されない" do
        params = { chore: valid_params[:chore].merge(user_id: other_user.id) }
        expect { post chores_path, params: params }.not_to change(other_user.chores, :count)
      end

      it "不正な値では作成されず、422が返る" do
        params = { chore: valid_params[:chore].merge(name: "") }
        expect { post chores_path, params: params }.not_to change(Chore, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "GET /chores/:id/edit" do
      it "自分の家事は編集画面を表示できる" do
        get edit_chore_path(create(:chore, user: user))
        expect(response).to have_http_status(:ok)
      end

      it "共通の家事は404になる" do
        get edit_chore_path(create(:chore, :master))
        expect(response).to have_http_status(:not_found)
      end

      it "他人の家事は404になる" do
        get edit_chore_path(create(:chore, user: other_user))
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "PATCH /chores/:id" do
      it "自分の家事は更新でき、詳細へリダイレクトされる" do
        chore = create(:chore, user: user)
        patch chore_path(chore), params: { chore: { name: "新しい名前" } }
        expect(chore.reload.name).to eq "新しい名前"
        expect(response).to redirect_to(chore_path(chore))
      end

      it "共通の家事は更新できない" do
        chore = create(:chore, :master, name: "元の名前")
        patch chore_path(chore), params: { chore: { name: "書き換え" } }
        expect(response).to have_http_status(:not_found)
        expect(chore.reload.name).to eq "元の名前"
      end

      it "他人の家事は更新できない" do
        chore = create(:chore, user: other_user, name: "元の名前")
        patch chore_path(chore), params: { chore: { name: "書き換え" } }
        expect(response).to have_http_status(:not_found)
        expect(chore.reload.name).to eq "元の名前"
      end

      it "不正な値では更新されず、422が返る" do
        chore = create(:chore, user: user, name: "元の名前")
        patch chore_path(chore), params: { chore: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
        expect(chore.reload.name).to eq "元の名前"
      end
    end

    describe "DELETE /chores/:id" do
      it "自分の家事は削除でき、303で一覧へリダイレクトされる" do
        chore = create(:chore, user: user)
        expect { delete chore_path(chore) }.to change(Chore, :count).by(-1)
        expect(response).to redirect_to(chores_path)
        expect(response).to have_http_status(:see_other)
      end

      it "共通の家事は削除できない" do
        chore = create(:chore, :master)
        expect { delete chore_path(chore) }.not_to change(Chore, :count)
        expect(response).to have_http_status(:not_found)
      end

      it "他人の家事は削除できない" do
        chore = create(:chore, user: other_user)
        expect { delete chore_path(chore) }.not_to change(Chore, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
