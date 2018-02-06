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

ActiveRecord::Schema.define(version: 20180206105803) do

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
    t.text "redirect_urls"
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
    t.integer "number_of_word_files", default: 0
    t.index ["content_id"], name: "index_content_items_on_content_id", unique: true
    t.index ["title"], name: "index_content_items_on_title"
  end

  create_table "dimensions_dates", primary_key: "date", id: :date, force: :cascade do |t|
    t.string "date_name", null: false
    t.string "date_name_abbreviated", null: false
    t.integer "year", null: false
    t.integer "quarter", null: false
    t.integer "month", null: false
    t.string "month_name", null: false
    t.string "month_name_abbreviated", null: false
    t.integer "week", null: false
    t.integer "day_of_year", null: false
    t.integer "day_of_quarter", null: false
    t.integer "day_of_month", null: false
    t.integer "day_of_week", null: false
    t.string "day_name", null: false
    t.string "day_name_abbreviated", null: false
    t.string "weekday_weekend", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_name"], name: "index_dimensions_dates_on_date_name"
    t.index ["date_name_abbreviated"], name: "index_dimensions_dates_on_date_name_abbreviated"
  end

  create_table "dimensions_items", force: :cascade do |t|
    t.string "content_id"
    t.string "title"
    t.string "link"
    t.string "description"
    t.string "organisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "latest"
    t.index ["content_id", "link", "organisation_id"], name: "dimensions_items_natural_key"
  end

  create_table "dimensions_items_temps", id: false, force: :cascade do |t|
    t.string "content_id"
    t.string "title"
    t.string "link"
    t.string "description"
    t.string "organisation_id"
    t.index ["content_id", "link", "organisation_id"], name: "dimensions_items_temps_natual_key"
  end

  create_table "dimensions_organisations", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.string "description"
    t.string "link"
    t.string "organisation_id"
    t.string "state"
    t.string "content_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "facts_metrics", force: :cascade do |t|
    t.date "dimensions_date_id"
    t.bigint "dimensions_item_id"
    t.bigint "dimensions_organisation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pageviews"
    t.integer "unique_pageviews"
    t.index ["dimensions_date_id", "dimensions_item_id"], name: "index_facts_metrics_unique", unique: true
    t.index ["dimensions_date_id"], name: "index_facts_metrics_on_dimensions_date_id"
    t.index ["dimensions_item_id"], name: "index_facts_metrics_on_dimensions_item_id"
    t.index ["dimensions_organisation_id"], name: "index_facts_metrics_on_dimensions_organisation_id"
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
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "allocations", "content_items", column: "content_id", primary_key: "content_id"
  add_foreign_key "allocations", "users", column: "uid", primary_key: "uid"
  add_foreign_key "facts_metrics", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_metrics", "dimensions_items"
  add_foreign_key "facts_metrics", "dimensions_organisations"
end
