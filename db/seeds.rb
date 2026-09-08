if Rails.env.development?
    Chore.destroy_all
    ChoreCategory.destroy_all
end

categories = {
  "掃除[定期]" => [
    { name: "掃除機がけ", estimated_minutes: 10, tools: "掃除機"},
    { name: "洗面所掃除", estimated_minutes: 15, tools: "マイクロファイバータオル"},
    { name: "洗濯", estimated_minutes: 20, tools: "洗濯洗剤、柔軟剤"},
  ],
  "食事・調理" => [
    { name: "買い出し", estimated_minutes: 30, tools: nil},
    { name: "夕食準備", estimated_minutes: 45, tools: nil},
  ],
  "掃除[不定期]" => [
    { name: "エアコン掃除", estimated_minutes: 20, tools: "ブラシ"},
  ]
}

categories.each do |category_name, chores|
  category = ChoreCategory.find_or_create_by!(name: category_name)

  chores.each do |chore_attrs|
    category.chores.find_or_create_by!(name: chore_attrs[:name]) do |chore|
      chore.user = nil
      chore.estimated_minutes = chore_attrs[:estimated_minutes]
      chore.tools = chore_attrs[:tools]
    end
  end
end

puts "カテゴリ数: #{ChoreCategory.count}"
puts "家事数: #{Chore.count}"