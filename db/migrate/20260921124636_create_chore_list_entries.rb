class CreateChoreListEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :chore_list_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chore, null: false, foreign_key: true
      t.date :list_date, null: false

      t.timestamps
    end
    add_index :chore_list_entries, [:user_id, :chore_id, :list_date], unique: true, name: "idx_unique_entry_per_day"
  end
end
