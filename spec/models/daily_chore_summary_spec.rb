require "rails_helper"

RSpec.describe DailyChoreSummary, type: :model do
  let(:user) { create(:user) }
  let(:today) { Date.current }

  def build_summary
    entries = ChoreListEntry.for_user(user).for_date(today).includes(:chore, :chore_record)
    described_class.new(entries, date: today)
  end

  def add_entry(estimated_minutes)
    create(:chore_list_entry, user: user, chore: create(:chore, user: user, estimated_minutes: estimated_minutes), list_date: today)
  end

  def complete(entry, actual_minutes)
    create(:chore_record, user: user, chore: entry.chore, chore_list_entry: entry, actual_minutes: actual_minutes)
  end

  context "完了・未完了のエントリーが混在する場合" do
    before do
      complete(add_entry(30), 25)
      complete(add_entry(20), 15)
      add_entry(10)
    end

    let(:summary) { build_summary }

    it "total_count はエントリーの件数を返す" do
      expect(summary.total_count).to eq 3
    end

    it "completed_count は記録があるエントリーの件数を返す" do
      expect(summary.completed_count).to eq 2
    end

    it "estimated_minutes_total は目安時間の合計を返す" do
      expect(summary.estimated_minutes_total).to eq 60
    end

    it "actual_minutes_total は実施時間の合計を返し、未完了は0として扱う" do
      expect(summary.actual_minutes_total).to eq 40
    end

    it "completion_rate は完了率を四捨五入した整数で返す" do
      expect(summary.completion_rate).to eq 67
    end
  end

  context "すべて完了している場合" do
    it "completion_rate は100を返す" do
      complete(add_entry(30), 30)
      expect(build_summary.completion_rate).to eq 100
    end
  end

  context "エントリーが0件の場合" do
    let(:summary) { build_summary }

    it "completion_rate はエラーにならず0を返す" do
      expect { summary.completion_rate }.not_to raise_error
      expect(summary.completion_rate).to eq 0
    end

    it "各合計は0を返す" do
      expect(summary.total_count).to eq 0
      expect(summary.estimated_minutes_total).to eq 0
      expect(summary.actual_minutes_total).to eq 0
    end
  end

  it "指定した日付を返す" do
    expect(build_summary.date).to eq today
  end
end
