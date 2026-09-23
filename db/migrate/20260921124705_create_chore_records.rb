class CreateChoreRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :chore_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chore, null: false, foreign_key: true
      t.references :chore_list_entry, null: false, foreign_key: true
      t.date :performed_on, null: false
      t.integer :actual_minutes
          
      t.timestamps
    end
  end
end
