# 指定日の「今日の家事リスト」を集計するクラス(DBテーブルは持たない)
class DailyChoreSummary
  attr_reader :date

  def initialize(entries, date:)
    @entries = entries.to_a # ここで一度だけ読み込み、以降はメモリ上で計算する
    @date = date
  end

  def total_count
    @entries.size
  end

  def completed_count
    @entries.count { |entry| entry.chore_record.present? }
  end

  def estimated_minutes_total
    @entries.sum(&:estimated_minutes) # ChoreListEntry で chore に delegate 済み
  end

  def actual_minutes_total
    @entries.sum { |entry| entry.chore_record&.actual_minutes.to_i } # actual_minutes はnil 許容なので to_i
  end

  def completion_rate
    return 0 if total_count.zero? # 家事が0件の日に ZeroDivisionError を防ぐ

    (completed_count * 100.0 / total_count).round
  end
end