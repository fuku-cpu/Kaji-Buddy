require "rails_helper"

RSpec.describe "ChoreRecords", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "未ログイン時" do
    it "記録一覧にアクセスするとログイン画面へリダイレクトされる" do
      get chore_records_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "ログイン時" do
    before { sign_in user }

    describe "GET /chore_records" do
      it "自分の今週の記録だけが表示される" do
        create(:chore_record, user: user, chore: create(:chore, user: user, name: "お風呂掃除"), performed_on: Date.current)
        create(:chore_record, user: user, chore: create(:chore, user: user, name: "窓拭き"), performed_on: Date.current.last_week)
        create(:chore_record, user: other_user, chore: create(:chore, user: other_user, name: "草むしり"), performed_on: Date.current)

        get chore_records_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("お風呂掃除")
        expect(response.body).not_to include("窓拭き")
        expect(response.body).not_to include("草むしり")
      end
    end

    describe "POST /chore_records" do
      let(:chore) { create(:chore, user: user, estimated_minutes: 20) }
      let!(:entry) { create(:chore_list_entry, user: user, chore: chore) }

      it "記録が作成され、Turbo Streamで画面が更新される" do
        expect {
          post chore_records_path, params: { chore_list_entry_id: entry.id, actual_minutes: 15 }, as: :turbo_stream
        }.to change(user.chore_records, :count).by(1)

        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('action="update" target="feedback_message"')
        expect(response.body).to include('action="replace" target="today_summary"')
      end

      it "実施時間が空の場合は目安時間で記録される" do
        post chore_records_path, params: { chore_list_entry_id: entry.id, actual_minutes: "" }, as: :turbo_stream
        expect(entry.reload.chore_record.actual_minutes).to eq 20
      end

      it "完了済みのエントリーには記録が追加されず、422が返る" do
        create(:chore_record, user: user, chore: chore, chore_list_entry: entry)
        expect {
          post chore_records_path, params: { chore_list_entry_id: entry.id, actual_minutes: 15 }, as: :turbo_stream
        }.not_to change(ChoreRecord, :count)
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "不正な実施時間では記録されず、422とエラー表示が返る" do
        expect {
          post chore_records_path, params: { chore_list_entry_id: entry.id, actual_minutes: 0 }, as: :turbo_stream
        }.not_to change(ChoreRecord, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include('action="update" target="feedback_message"')
      end

      it "他人のエントリーは404になり記録されない" do
        others_entry = create(:chore_list_entry, user: other_user)
        expect {
          post chore_records_path, params: { chore_list_entry_id: others_entry.id, actual_minutes: 15 }, as: :turbo_stream
        }.not_to change(ChoreRecord, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE /chore_records/:id" do
      it "自分の記録を取り消せ、Turbo Streamで画面が更新される" do
        record = create(:chore_record, user: user)
        expect { delete chore_record_path(record), as: :turbo_stream }.to change(ChoreRecord, :count).by(-1)
        expect(response.media_type).to eq Mime[:turbo_stream]
        expect(response.body).to include('action="replace" target="today_summary"')
      end

      it "他人の記録は404になり削除されない" do
        record = create(:chore_record, user: other_user)
        expect { delete chore_record_path(record), as: :turbo_stream }.not_to change(ChoreRecord, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
