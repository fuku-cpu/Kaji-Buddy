require "rails_helper"

RSpec.describe ChoreListEntry, type: :model do
  let(:user) { create(:user) }
  let(:chore) { create(:chore, user: user) }

  describe "ファクトリ" do
    it "有効なエントリーを作成できる" do
      expect(build(:chore_list_entry)).to be_valid
    end
  end

  describe "バリデーション" do
    it "list_dateが空の場合は無効" do
      entry = build(:chore_list_entry, list_date: nil)
      expect(entry).to be_invalid
      expect(entry.errors.of_kind?(:list_date, :blank)).to be true
    end

    describe "重複登録" do
      let(:today) { Date.current }

      before { create(:chore_list_entry, user: user, chore: chore, list_date: today) }

      it "同じユーザー・同じ家事・同じ日付は無効" do
        entry = build(:chore_list_entry, user: user, chore: chore, list_date: today)
        expect(entry).to be_invalid
        expect(entry.errors.of_kind?(:chore_id, :taken)).to be true
      end

      it "日付が違えば有効" do
        expect(build(:chore_list_entry, user: user, chore: chore, list_date: today + 1)).to be_valid
      end

      it "ユーザーが違えば有効" do
        common_chore = create(:chore, :master)
        create(:chore_list_entry, user: user, chore: common_chore, list_date: today)
        expect(build(:chore_list_entry, user: create(:user), chore: common_chore, list_date: today)).to be_valid
      end
    end
  end

  describe "スコープ" do
    let(:other_user) { create(:user) }
    let!(:today_entry) { create(:chore_list_entry, user: user, list_date: Date.current) }
    let!(:yesterday_entry) { create(:chore_list_entry, user: user, list_date: Date.yesterday) }
    let!(:other_entry) { create(:chore_list_entry, user: other_user, list_date: Date.current) }

    it ".for_user は自分のエントリーだけを返す" do
      expect(ChoreListEntry.for_user(user)).to contain_exactly(today_entry, yesterday_entry)
    end

    it ".for_date は指定日のエントリーだけを返す" do
      expect(ChoreListEntry.for_date(Date.current)).to contain_exactly(today_entry, other_entry)
    end

    it "組み合わせると自分の今日のエントリーだけを返す" do
      expect(ChoreListEntry.for_user(user).for_date(Date.current)).to contain_exactly(today_entry)
    end
  end

  describe "委譲" do
    it "家事の名前と目安時間を参照できる" do
      entry = build(:chore_list_entry, chore: build(:chore, name: "洗濯", estimated_minutes: 30))
      expect(entry.name).to eq "洗濯"
      expect(entry.estimated_minutes).to eq 30
    end
  end

  describe "#completed?" do
    let(:entry) { create(:chore_list_entry, user: user, chore: chore) }

    it "実施記録がなければ false" do
      expect(entry.completed?).to be false
    end

    it "実施記録があれば true" do
      create(:chore_record, user: user, chore: chore, chore_list_entry: entry)
      expect(entry.reload.completed?).to be true
    end
  end

  describe "削除時の挙動" do
    let!(:entry) { create(:chore_list_entry, user: user, chore: chore) }

    it "実施記録がなければ削除できる" do
      expect { entry.destroy }.to change(ChoreListEntry, :count).by(-1)
    end

    context "実施記録がある場合" do
      before { create(:chore_record, user: user, chore: chore, chore_list_entry: entry) }

      it "削除できず、エラーが追加される" do
        expect { entry.reload.destroy }.not_to change(ChoreListEntry, :count)
        expect(entry.errors[:base]).to be_present
      end
    end
  end
end
