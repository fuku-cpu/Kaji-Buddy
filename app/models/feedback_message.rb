class FeedbackMessage
  # %{count} = 今日何個目か / %{minutes} = 目安より何分早かったか
  MESSAGES = {
    friend: {
      all_completed: [
        "今日の家事、全部終わったね！ゆっくり休んでね",
        "おつかれ！全部やり切ったの、ほんとにえらいよ。"
      ],
      faster: [
        "目安より%{minutes}分も早かったね！手際いいなあ",
        "早いね！だんだん慣れてきたね"
      ],
      nth: [
        "今日はもう%{count}個目だね。この調子で終わらせていこう",
        "%{count}個目お疲れ様！いいペースだね"
      ],
      default: [
        "お疲れ様！一つ片付いたね",
        "やったね。ちゃんとやることやってえらいな"
      ]
    },
    coach: {
      all_completed: [
        "全メニュー完了！今日のあなたは最高だ！",
        "やり切った！しっかり休むのも大事なトレーニングだぞ！"
      ],
      faster: [
        "目安よりも%{minutes}分短縮！自己ベスト更新だ！",
        "テキパキこなせたな！その調子！"
      ],
      nth: [
        "%{count}個目クリア！勢いに乗ってるぞ！",
        "今日%{count}本目！着実に積み上げてるな！"
      ],
      default: [
        "ナイスファイト！一歩前進だ！",
        "よし、よくやった！"
      ]
    },
    butler: {
      all_completed: [
        "本日のご予定、すべて完了でございます。どうぞごゆるりとお過ごしください",
        "お見事でございます。今宵は心置きなくお休みくださいませ"
      ],
      faster: [
        "目安より%{minutes}分早いお仕事、感服いたしました",
        "テキパキとこなされましたね。さすがでございます"
      ],
      nth: [
        "本日%{count}件目のお勤め、お疲れ様でございます",
        "%{count}件目でございますね。見事な積み重ねです"
      ],
      default: [
        "お疲れ様でございました",
        "ひとつ片付きましたね、ご立派でございます"
      ]
    }
  }.freeze

  attr_reader :chore_record

  def initialize(chore_record)
    @chore_record = chore_record
    @user = chore_record.user
  end

  # キャラ選択画面の見本用
  def self.sample_for(character)
    MESSAGES.dig(character.to_sym, :default).first
  end

  def text
    @text ||= format(
      MESSAGES.dig(character, situation).sample,
      count: today_count,
      minutes: saved_minutes
    )
  end

  def character
    @user.character_type.to_sym
  end

  def situation
    @situation ||=
      if all_completed?
        :all_completed
      elsif faster?
        :faster
      elsif today_count >= 2
        :nth
      else
        :default
      end
  end

  private

  # その日のリストに「記録が無いエントリー」が1件も残っていない
  def all_completed?
    ChoreListEntry.for_user(@user)
                  .for_date(chore_record.performed_on)
                  .where.missing(:chore_record)
                  .none?
  end

  def faster?
    saved_minutes.positive?
  end

  def saved_minutes
    chore_record.chore.estimated_minutes - chore_record.actual_minutes
  end

  def today_count
    @today_count ||= ChoreRecord.where(user: @user, performed_on: chore_record.performed_on).count
  end
end
