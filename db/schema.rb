# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_21_124705) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chore_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "chore_list_entries", force: :cascade do |t|
    t.bigint "chore_id", null: false
    t.datetime "created_at", null: false
    t.date "list_date", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chore_id"], name: "index_chore_list_entries_on_chore_id"
    t.index ["user_id", "chore_id", "list_date"], name: "idx_unique_entry_per_day", unique: true
    t.index ["user_id"], name: "index_chore_list_entries_on_user_id"
  end

  create_table "chore_records", force: :cascade do |t|
    t.integer "actual_minutes"
    t.bigint "chore_id", null: false
    t.bigint "chore_list_entry_id", null: false
    t.datetime "created_at", null: false
    t.date "performed_on", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chore_id"], name: "index_chore_records_on_chore_id"
    t.index ["chore_list_entry_id"], name: "index_chore_records_on_chore_list_entry_id"
    t.index ["user_id"], name: "index_chore_records_on_user_id"
  end

  create_table "chores", force: :cascade do |t|
    t.bigint "chore_category_id"
    t.datetime "created_at", null: false
    t.integer "estimated_minutes", null: false
    t.text "memo"
    t.string "name", null: false
    t.string "tools"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["chore_category_id"], name: "index_chores_on_chore_category_id"
    t.index ["user_id"], name: "index_chores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chore_list_entries", "chores"
  add_foreign_key "chore_list_entries", "users"
  add_foreign_key "chore_records", "chore_list_entries"
  add_foreign_key "chore_records", "chores"
  add_foreign_key "chore_records", "users"
  add_foreign_key "chores", "chore_categories"
  add_foreign_key "chores", "users"
end
