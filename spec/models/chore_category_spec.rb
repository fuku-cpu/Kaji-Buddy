require "rails_helper"

RSpec.describe ChoreCategory, type: :model do
  describe "ファクトリ" do
    it "有効なカテゴリを作成できる" do
      expect(build(:chore_category)).to be_valid
    end
  end

  describe "バリデーション" do
    describe "name" do
      it "空の場合は無効" do
        category = build(:chore_category, name: "")
        expect(category).to be_invalid
        expect(category.errors.of_kind?(:name, :blank)).to be true
      end

      it "255文字の場合は有効" do
        expect(build(:chore_category, name: "a" * 255)).to be_valid
      end

      it "256文字の場合は無効" do
        category = build(:chore_category, name: "a" * 256)
        expect(category).to be_invalid
        expect(category.errors.of_kind?(:name, :too_long)).to be true
      end
    end
  end
end
