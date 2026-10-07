module ChoreRecordsHelper
  WDAYS = %w[日 月 火 水 木 金 土].freeze

  def chore_feedback_message(record)
    if (saved = record.minutes_saved)
      "予定よりも#{saved}分早く終わりました。テキパキこなせましたね！"
    else
    "お疲れ様です！"
    end
  end

  # 150 → "2時間30分"、 45 → "45分"
  def format_minutes(minutes)
    hours, mins = minutes.to_i.divmod(60)
    return "#{mins}分" if hours.zero?

    mins.zero? ? "#{hours}時間" : "#{hours}時間#{mins}分"
  end

  # 今日 → "今日"、 昨日 → "昨日"、 それ以外 → "10月1日(木)"
  def record_date_label(date)
    return "今日" if date == Date.current
    return "昨日" if date == Date.yesterday

    "#{date.month}月#{date.day}日(#{WDAYS[date.wday]})"
  end

  # 今週の範囲 → "9/28～10/4"
  def period_label(period)
    "#{period.first.month}/#{period.first.day}～#{period.last.month}/#{period.last.day}"
  end
end