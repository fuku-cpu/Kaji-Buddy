class TightenChoreRecords < ActiveRecord::Migration[8.1]
  def change
    # 実施時間を空にできないようにする
    change_column_null :chore_records, :actual_minutes, false

    # 1つのエントリーに記録は1件だけ
    remove_index :chore_records, :chore_list_entry_id
    add_index :chore_records, :chore_list_entry_id, unique: true

    # 「誰の・いつの記録か」で探しやすくなる
    add_index :chore_records, [:user_id, :performed_on]
  end
end
