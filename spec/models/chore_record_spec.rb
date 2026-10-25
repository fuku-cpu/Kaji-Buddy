# spec/models/chore_record_spec.rb
require "rails_helper"

RSpec.describe ChoreRecord, type: :model do
  describe "ファクトリ" do
    it "有効な記録を作成できる" do
      expect(build(:chore_record)).to be_valid
    end
  end

  describe "バリデーション" do
    it "performed_onが空の場合は無効" do
      record = build(:chore_record, performed_on: nil)
      expect(record).to be_invalid
      expect(record.errors.of_kind?(:performed_on, :blank)).to be true
    end

    describe "actual_minutes" do
      it "空の場合は家事の目安時間が入る" do
        record = build(:chore_record, chore: build(:chore, estimated_minutes: 25), actual_minutes: nil)
        expect(record).to be_valid
        expect(record.actual_minutes).to eq 25
      end

      it "空で家事もない場合は無効" do
        record = build(:chore_record, chore: nil, actual_minutes: nil)
        expect(record).to be_invalid
        expect(record.errors.of_kind?(:actual_minutes, :blank)).to be true
      end

      it "0の場合は無効" do
        record = build(:chore_record, actual_minutes: 0)
        expect(record).to be_invalid
        expect(record.errors.of_kind?(:actual_minutes, :greater_than)).to be true
      end

      it "1の場合は有効" do
        expect(build(:chore_record, actual_minutes: 1)).to be_valid
      end

      it "小数の場合は無効" do
        record = build(:chore_record, actual_minutes: 1.5)
        expect(record).to be_invalid
        expect(record.errors.of_kind?(:actual_minutes, :not_an_integer)).to be true
      end
    end

    it "同じエントリーに2件目の記録は作れない" do
      existing = create(:chore_record)
      record = build(:chore_record, chore_list_entry: existing.chore_list_entry)
      expect(record).to be_invalid
      expect(record.errors.of_kind?(:chore_list_entry_id, :taken)).to be true
    end
  end

  describe "スコープ" do
    let!(:old_record) { create(:chore_record, performed_on: Date.new(2026, 10, 1)) }
    let!(:mid_record) { create(:chore_record, performed_on: Date.new(2026, 10, 10)) }
    let!(:new_record) { create(:chore_record, performed_on: Date.new(2026, 10, 20)) }

    it ".performed_within は期間内の記録だけを返す（両端を含む）" do
      range = Date.new(2026, 10, 1)..Date.new(2026, 10, 10)
      expect(ChoreRecord.performed_within(range)).to contain_exactly(old_record, mid_record)
    end

    it ".recent_first は実施日の新しい順に並べる" do
      expect(ChoreRecord.recent_first).to eq [new_record, mid_record, old_record]
    end

    it ".recent_first は同じ実施日なら作成日時の新しい順に並べる" do
      date = Date.new(2026, 10, 25)
      earlier = create(:chore_record, performed_on: date, created_at: 2.hours.ago)
      later = create(:chore_record, performed_on: date, created_at: 1.hour.ago)
      expect(ChoreRecord.recent_first.first(2)).to eq [later, earlier]
    end
  end

  describe "#minutes_saved" do
    let(:chore) { build(:chore, estimated_minutes: 30) }

    it "目安より早ければ短縮した分数を返す" do
      expect(build(:chore_record, chore: chore, actual_minutes: 20).minutes_saved).to eq 10
    end

    it "目安と同じなら nil" do
      expect(build(:chore_record, chore: chore, actual_minutes: 30).minutes_saved).to be_nil
    end

    it "目安より遅ければ nil" do
      expect(build(:chore_record, chore: chore, actual_minutes: 40).minutes_saved).to be_nil
    end
  end
end