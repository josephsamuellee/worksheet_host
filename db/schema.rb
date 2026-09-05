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

ActiveRecord::Schema[7.2].define(version: 2026_09_05_224753) do
  create_table "worksheet_responses", force: :cascade do |t|
    t.integer "worksheet_template_version_id", null: false
    t.string "status", default: "draft", null: false
    t.json "answers", default: {}, null: false
    t.string "last_edited_field_key"
    t.datetime "last_edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_worksheet_responses_on_status"
    t.index ["worksheet_template_version_id"], name: "index_responses_on_template_version_id"
  end

  create_table "worksheet_template_versions", force: :cascade do |t|
    t.integer "worksheet_id", null: false
    t.string "content_hash", null: false
    t.text "source_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["worksheet_id", "content_hash"], name: "index_template_versions_on_worksheet_and_hash", unique: true
    t.index ["worksheet_id"], name: "index_worksheet_template_versions_on_worksheet_id"
  end

  create_table "worksheets", force: :cascade do |t|
    t.string "slug", null: false
    t.string "name", null: false
    t.string "source_filename", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_worksheets_on_slug", unique: true
    t.index ["source_filename"], name: "index_worksheets_on_source_filename", unique: true
  end

  add_foreign_key "worksheet_responses", "worksheet_template_versions"
  add_foreign_key "worksheet_template_versions", "worksheets"
end
