require "rails_helper"

RSpec.describe ChoreRecordsHelper, type: :helper do
  describe "#format_minutes" do
    it "60分未満は分だけで表示する" do
      expect(helper.format_minutes(0)).to eq "0分"
      expect(helper.format_minutes(45)).to eq "45分"
      expect(helper.format_minutes(59)).to eq "59分"
    end

    it "分が0の場合は時間だけで表示する" do
      expect(helper.format_minutes(60)).to eq "1時間"
      expect(helper.format_minutes(120)).to eq "2時間"
    end

    it "時間と分がある場合は両方を表示する" do
      expect(helper.format_minutes(90)).to eq "1時間30分"
      expect(helper.format_minutes(150)).to eq "2時間30分"
    end

    it "nilの場合は0分と表示する" do
      expect(helper.format_minutes(nil)).to eq "0分"
    end
  end

  describe "#record_date_label" do
    around do |example|
      travel_to(Date.new(2026, 10, 15)) { example.run }
    end

    it "今日の日付は「今日」と表示する" do
      expect(helper.record_date_label(Date.new(2026, 10, 15))).to eq "今日"
    end

    it "昨日の日付は「昨日」と表示する" do
      expect(helper.record_date_label(Date.new(2026, 10, 14))).to eq "昨日"
    end

    it "一昨日以前の日付は月日と曜日で表示する" do
      expect(helper.record_date_label(Date.new(2026, 10, 13))).to eq "10月13日(火)"
      expect(helper.record_date_label(Date.new(2026, 10, 1))).to eq "10月1日(木)"
    end

    it "未来の日付は月日と曜日で表示する" do
      expect(helper.record_date_label(Date.new(2026, 10, 16))).to eq "10月16日(金)"
    end
  end

  describe "#period_label" do
    it "週の範囲を「月/日～月/日」で表示する" do
      expect(helper.period_label(Date.new(2026, 10, 15).all_week)).to eq "10/12～10/18"
    end

    it "月をまたぐ週も正しく表示する" do
      expect(helper.period_label(Date.new(2026, 10, 1).all_week)).to eq "9/28～10/4"
    end
  end
end
