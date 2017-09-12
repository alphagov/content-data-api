# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170912052906) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocations", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_allocations_on_content_id", unique: true
    t.index ["uid"], name: "index_allocations_on_uid"
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.string "content_id", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "change_title"
    t.boolean "change_description"
    t.boolean "change_body"
    t.boolean "change_attachments"
    t.boolean "outdated"
    t.boolean "redundant"
    t.boolean "reformat"
    t.boolean "similar"
    t.text "similar_urls"
    t.text "notes"
    t.index ["content_id"], name: "index_audits_on_content_id", unique: true
    t.index ["uid"], name: "index_audits_on_uid"
  end

  create_table "content_items", id: :serial, force: :cascade do |t|
    t.string "content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "public_updated_at"
    t.string "base_path"
    t.string "title"
    t.string "document_type"
    t.string "description"
    t.integer "one_month_page_views", default: 0
    t.integer "number_of_pdfs", default: 0
    t.integer "six_months_page_views", default: 0
    t.string "publishing_app"
    t.string "locale", null: false
    t.index ["content_id"], name: "index_content_items_on_content_id", unique: true
    t.index ["title"], name: "index_content_items_on_title"
  end

  create_table "links", id: :serial, force: :cascade do |t|
    t.string "source_content_id"
    t.string "link_type"
    t.string "target_content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_type"], name: "index_links_on_link_type"
    t.index ["source_content_id"], name: "index_links_on_source_content_id"
    t.index ["target_content_id"], name: "index_links_on_target_content_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_questions_on_type"
  end

  create_table "report_rows", force: :cascade do |t|
    t.string "content_id"
    t.json "data"
    t.index ["content_id"], name: "index_report_rows_on_content_id", unique: true
  end

  create_table "responses", id: :serial, force: :cascade do |t|
    t.integer "audit_id"
    t.integer "question_id"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["audit_id"], name: "index_responses_on_audit_id"
    t.index ["question_id"], name: "index_responses_on_question_id"
  end

  create_table "subthemes", force: :cascade do |t|
    t.bigint "theme_id"
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id", "name"], name: "index_subthemes_on_theme_id_and_name", unique: true
    t.index ["theme_id"], name: "index_subthemes_on_theme_id"
  end

  create_table "taxonomy_projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taxonomy_todos", force: :cascade do |t|
    t.bigint "content_item_id"
    t.bigint "taxonomy_project_id"
    t.datetime "completed_at"
    t.string "completed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "todo"
    t.index ["content_item_id"], name: "index_taxonomy_todos_on_content_item_id"
    t.index ["taxonomy_project_id"], name: "index_taxonomy_todos_on_taxonomy_project_id"
  end

  create_table "taxonomy_todos_terms", id: false, force: :cascade do |t|
    t.bigint "term_id", null: false
    t.bigint "taxonomy_todo_id", null: false
    t.index ["taxonomy_todo_id"], name: "index_taxonomy_todos_terms_on_taxonomy_todo_id"
    t.index ["term_id", "taxonomy_todo_id"], name: "index_terms_taxonomy_todos", unique: true
    t.index ["term_id"], name: "index_taxonomy_todos_terms_on_term_id"
  end

  create_table "terms", force: :cascade do |t|
    t.string "name"
    t.bigint "taxonomy_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["taxonomy_project_id"], name: "index_terms_on_taxonomy_project_id"
  end

  create_table "themes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_themes_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "taxonomy_todos", "content_items"
  add_foreign_key "taxonomy_todos", "taxonomy_projects"
end
