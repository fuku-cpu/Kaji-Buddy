require "rails_helper"

RSpec.describe Chore, type: :model do
  describe "ファクトリ" do
    it "有効な家事を作成できる" do
      expect(build(:chore)).to be_valid
    end

    it "ユーザーなし（共通の家事）でも有効" do
      expect(build(:chore, :master)).to be_valid
    end
  end

  describe "バリデーション" do
    describe "name" do
      it "空の場合は無効" do
        chore = build(:chore, name: "")
        expect(chore).to be_invalid
        expect(chore.errors.of_kind?(:name, :blank)).to be true
      end

      it "255文字の場合は有効" do
         expect(build(:chore, name: "a" * 255)).to be_valid
      end

      it "256文字の場合は無効" do
        chore = build(:chore, name: "a" * 256)
        expect(chore).to be_invalid
        expect(chore.errors.of_kind?(:name, :too_long)).to be true
      end
    end

    describe "estimated_minutes" do
      it "空の場合は無効" do
        chore = build(:chore, estimated_minutes: nil)
        expect(chore).to be_invalid
        expect(chore.errors.of_kind?(:estimated_minutes, :blank)).to be true
      end

      it "0の場合は無効" do
        chore = build(:chore, estimated_minutes: 0)
        expect(chore).to be_invalid
        expect(chore.errors.of_kind?(:estimated_minutes, :greater_than)).to be true
      end

      it "1の場合は有効" do
        expect(build(:chore, estimated_minutes: 1)).to be_valid
      end

      it "1440の場合は有効" do
        expect(build(:chore, estimated_minutes: 1440)).to be_valid
      end

      it "1441の場合は無効" do
          chore = build(:chore, estimated_minutes: 1441)
          expect(chore).to be_invalid
          expect(chore.errors.of_kind?(:estimated_minutes, :less_than_or_equal_to)).to be true
      end
    end

    describe "chore_category" do
      it "カテゴリが無い場合は無効" do
        chore = build(:chore, chore_category: nil)
        expect(chore).to be_invalid
        expect(chore.errors.of_kind?(:chore_category, :blank)).to be true
      end
    end
  end

  describe "スコープ" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:own_chore) { create(:chore, user: user) }
    let!(:common_chore) { create(:chore, :master) }
    let!(:other_chore) { create(:chore, user: other_user) }

    describe ".for_user" do
      it "自分の家事と共通の家事だけを返し、他人の家事は返さない" do
        expect(Chore.for_user(user)).to contain_exactly(own_chore, common_chore)
      end
    end

    describe ".common" do
      it "共通の家事だけを返す" do
        expect(Chore.common).to contain_exactly(common_chore)
      end
    end
  end

  describe "インスタンスメソッド" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe "#owned_by?" do
      it "自分の家事なら true" do
        expect(build(:chore, user: user).owned_by?(user)).to be true
      end

      it "他人の家事なら false" do
        expect(build(:chore, user: other_user).owned_by?(user)).to be false
      end

      it "共通の家事なら false" do
        expect(build(:chore, :master).owned_by?(user)).to be false
      end
    end

    describe "#common?" do
      it "共通の家事なら true" do
        expect(build(:chore, :master).common?).to be true
      end

      it "ユーザーの家事なら false" do
        expect(build(:chore, user: user).common?).to be false
      end
    end
  end

  describe "削除時の挙動" do
    let(:user) { create(:user) }
    let!(:chore) { create(:chore, user: user) }
    let!(:entry) { create(:chore_list_entry, user: user, chore: chore) }

    it "今日の家事リストも削除される" do
      expect { chore.destroy }.to change(ChoreListEntry, :count).by(-1)
    end

    context "実施記録がある場合" do
      let!(:record) { create(:chore_record, user: user, chore: chore, chore_list_entry: entry) }

      it "実施記録も削除される" do
        expect { chore.destroy }.to change(ChoreRecord, :count).by(-1)
      end

      it "今日の家事リストも削除される" do
        expect { chore.destroy }.to change(ChoreListEntry, :count).by(-1)
      end
    end
  end
end
