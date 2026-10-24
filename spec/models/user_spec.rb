require "rails_helper"

RSpec.describe User, type: :model do
  describe "ファクトリ" do
    it "有効なユーザーを作成できる" do
      expect(build(:user)).to be_valid
    end
  end

  describe "バリデーション" do
    describe "name" do
      it "空の場合は無効" do
        user = build(:user, name: "")
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:name, :blank)).to be true
      end
    end

    describe "email" do
      it "空の場合は無効" do
        user = build(:user, email: "")
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:email, :blank)).to be true
      end

      it "形式が不正な場合は無効" do
        user = build(:user, email: "invalid-email")
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:email, :invalid)).to be true
      end

      it "重複している場合は無効（大文字小文字は区別しない）" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "TEST@example.com")
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:email, :taken)).to be true
      end
    end

    describe "password" do
      it "空の場合は無効" do
        user = build(:user, password: "", password_confirmation: "")
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:password, :blank)).to be true
      end

      it "5文字以下の場合は無効" do
        user = build(:user, password: "a" * 5, password_confirmation: "a" * 5)
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:password, :too_short)).to be true
      end

      it "6文字以上の場合は有効" do
        user = build(:user, password: "a" * 6, password_confirmation: "a" * 6)
        expect(user).to be_valid
      end

      it "確認用と一致しない場合は無効" do
        user = build(:user, password_confirmation: "different")
        expect(user).to be_invalid
        expect(user.errors.of_kind?(:password_confirmation, :confirmation)).to be true
      end
    end
  end

  describe "character_type" do
    it "初期値は friend" do
      expect(build(:user).character_type).to eq "friend"
    end

    it "friend / coach / butler のいずれかなら有効" do
      %w[friend coach butler].each do |type|
        expect(build(:user, character_type: type)).to be_valid
      end
    end

    it "定義されていない値の場合は無効（例外ではなくバリデーションエラーになる）" do
      user = build(:user, character_type: "invalid")
      expect(user).to be_invalid
      expect(user.errors.of_kind?(:character_type, :inclusion)).to be true
    end

    it "nilの場合は無効" do
      user = build(:user, character_type: nil)
      expect(user).to be_invalid
    end
  end
end
