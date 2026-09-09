class CreateChores < ActiveRecord::Migration[8.1]
  def change
    create_table :chores do |t|
      t.string :name, null:false
      t.integer :estimated_minutes, null:false
      t.string :tools
      t.text :memo
      t.references :user, foreign_key: true
      t.references :chore_category, foreign_key: true

      t.timestamps
    end
  end
end
