require "rails_helper"

RSpec.describe "ChoreListEntries", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "未ログイン時" do
    it "一覧にアクセスするとログイン画面へリダイレクトされる" do
      get chore_list_entries_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン時" do
    before { sign_in user }

    describe "GET /chore_list_entries/guide" do
      it "使い方画面を表示できる" do
        get guide_chore_list_entries_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /chore_list_entries" do
      it "自分の今日のエントリーだけが表示される" do
        create(:chore_list_entry, user: user, chore: create(:chore, user: user, name: "お風呂掃除"))
        create(:chore_list_entry, user: user, chore: create(:chore, user: user, name: "窓拭き"), list_date: Date.yesterday)
        create(:chore_list_entry, user: other_user, chore: create(:chore, user: other_user, name: "草むしり"))

        get chore_list_entries_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("お風呂掃除")
        expect(response.body).not_to include("窓拭き")
        expect(response.body).not_to include("草むしり")
      end
    end

    describe "GET /chore_list_entries/new" do
      it "追加画面を表示できる" do
        get new_chore_list_entry_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /chore_list_entries" do
      let(:chore_a) { create(:chore, user: user) }
      let(:chore_b) { create(:chore, :master) }

      it "選択した家事が今日のリストに追加され、トップへリダイレクトされる" do
        expect {
          post chore_list_entries_path, params: { chore_ids: [ chore_a.id, chore_b.id ] }
        }.to change(user.chore_list_entries.for_date(Date.current), :count).by(2)
        expect(response).to redirect_to(root_path)
      end

      it "何も選択しない場合は追加されず、追加画面へリダイレクトされる" do
        expect {
          post chore_list_entries_path, params: { chore_ids: [] }
        }.not_to change(ChoreListEntry, :count)
        expect(response).to redirect_to(new_chore_list_entry_path)
      end

      it "他人の家事のIDを送っても追加されない" do
        others_chore = create(:chore, user: other_user)
        expect {
          post chore_list_entries_path, params: { chore_ids: [ others_chore.id ] }
        }.not_to change(ChoreListEntry, :count)
      end

      it "追加済みの家事を再度送っても重複して追加されない" do
        create(:chore_list_entry, user: user, chore: chore_a)
        expect {
          post chore_list_entries_path, params: { chore_ids: [ chore_a.id ] }
        }.not_to change(ChoreListEntry, :count)
        expect(response).to redirect_to(root_path)
      end
    end

    describe "DELETE /chore_list_entries/:id" do
      let!(:entry) { create(:chore_list_entry, user: user) }

      it "未完了のエントリーは外せて、303でリダイレクトされる" do
        expect { delete chore_list_entry_path(entry) }.to change(ChoreListEntry, :count).by(-1)
        expect(response).to redirect_to(chore_list_entries_path)
        expect(response).to have_http_status(:see_other)
      end

      it "完了済みのエントリーは外せない" do
        create(:chore_record, user: user, chore: entry.chore, chore_list_entry: entry)
        expect { delete chore_list_entry_path(entry) }.not_to change(ChoreListEntry, :count)
        expect(response).to have_http_status(:see_other)
        expect(flash[:alert]).to eq "完了済みの家事は外せません"
      end

      it "他人のエントリーは404になり削除されない" do
        others_entry = create(:chore_list_entry, user: other_user)
        expect { delete chore_list_entry_path(others_entry) }.not_to change(ChoreListEntry, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
