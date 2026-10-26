require "rails_helper"

RSpec.describe FeedbackMessage, type: :model do
  let(:user) { create(:user) }
  let(:today) { Date.current }

  def add_entry(owner: user, estimated_minutes: 30, list_date: today)
    chore = create(:chore, user: owner, estimated_minutes: estimated_minutes)
    create(:chore_list_entry, user: owner, chore: chore, list_date: list_date)
  end

  def complete(entry, actual_minutes)
    create(:chore_record, user: entry.user, chore: entry.chore, chore_list_entry: entry,
                          actual_minutes: actual_minutes, performed_on: entry.list_date)
  end

  def feedback_for(record)
    described_class.new(record)
  end

  describe "#situation" do
    it "その日のリストがすべて完了した場合は :all_completed" do
      record = complete(add_entry, 30)
      expect(feedback_for(record).situation).to eq :all_completed
    end

    it "目安より早く終わった場合は :faster" do
      add_entry
      record = complete(add_entry(estimated_minutes: 30), 20)
      expect(feedback_for(record).situation).to eq :faster
    end

    it "今日2件目以降の記録の場合は :nth" do
      add_entry
      complete(add_entry, 30)
      record = complete(add_entry, 30)
      expect(feedback_for(record).situation).to eq :nth
    end

    it "いずれでもない場合（今日1件目・目安どおり・未完了あり）は :default" do
      add_entry
      record = complete(add_entry, 30)
      expect(feedback_for(record).situation).to eq :default
    end

    describe "優先順位" do
      it "全完了かつ目安より早い場合は :all_completed が優先される" do
        record = complete(add_entry(estimated_minutes: 30), 20)
        expect(feedback_for(record).situation).to eq :all_completed
      end

      it "目安より早くかつ今日2件目以降の場合は :faster が優先される" do
        add_entry
        complete(add_entry, 30)
        record = complete(add_entry(estimated_minutes: 30), 20)
        expect(feedback_for(record).situation).to eq :faster
      end
    end

    it "目安より遅い場合は :faster にならない" do
      add_entry
      record = complete(add_entry(estimated_minutes: 30), 40)
      expect(feedback_for(record).situation).to eq :default
    end

    it "他のユーザーや別の日の未完了エントリーは全完了の判定に影響しない" do
      add_entry(owner: create(:user))
      add_entry(list_date: today - 1)
      record = complete(add_entry, 30)
      expect(feedback_for(record).situation).to eq :all_completed
    end
  end

  describe "#text" do
    it "ユーザーのキャラクターと状況に対応する候補から選ばれ、分数が置き換わる" do
      user.update!(character_type: :coach)
      add_entry
      record = complete(add_entry(estimated_minutes: 30), 20)

      candidates = described_class::MESSAGES[:coach][:faster].map { |m| format(m, count: 1, minutes: 10) }
      expect(candidates).to include(feedback_for(record).text)
    end

    it "今日何件目かが置き換わり、プレースホルダーが残らない" do
      add_entry
      complete(add_entry, 30)
      record = complete(add_entry, 30)
      text = feedback_for(record).text

      candidates = described_class::MESSAGES[:friend][:nth].map { |m| format(m, count: 2, minutes: 0) }
      expect(candidates).to include(text)
      expect(text).not_to include("%{")
    end
  end

  describe ".sample_for" do
    it "指定したキャラクターのデフォルトメッセージの1件目を返す" do
      expect(described_class.sample_for("butler")).to eq described_class::MESSAGES[:butler][:default].first
    end
  end
end
