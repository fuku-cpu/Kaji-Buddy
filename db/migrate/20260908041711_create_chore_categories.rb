class CreateChoreCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :chore_categories do |t|
      t.string :name, null:false
      t.timestamps
    end
  end
end
