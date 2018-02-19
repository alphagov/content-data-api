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

ActiveRecord::Schema.define(version: 20180214145821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "latest"
    t.string "description"
    t.string "title"
    t.string "base_path"
    t.json "raw_json"
    t.integer "number_of_pdfs"
    t.index ["base_path", "latest"], name: "index_dimensions_items_on_base_path_and_latest"
    t.index ["latest", "base_path"], name: "index_dimensions_items_on_latest_and_base_path"
  end

  create_table "dimensions_items_temps", id: false, force: :cascade do |t|
    t.string "content_id"
    t.string "description"
    t.string "title"
    t.string "base_path"
  end

  create_table "events_gas", force: :cascade do |t|
    t.date "date"
    t.string "page_path"
    t.integer "pageviews"
    t.integer "unique_pageviews"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_path", "date"], name: "index_events_gas_on_page_path_and_date"
  end

  create_table "facts_metrics", force: :cascade do |t|
    t.date "dimensions_date_id"
    t.bigint "dimensions_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pageviews", default: 0
    t.integer "unique_pageviews", default: 0
    t.index ["dimensions_date_id", "dimensions_item_id"], name: "index_facts_metrics_unique", unique: true
    t.index ["dimensions_date_id"], name: "index_facts_metrics_on_dimensions_date_id"
    t.index ["dimensions_item_id"], name: "index_facts_metrics_on_dimensions_item_id"
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

  add_foreign_key "facts_metrics", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_metrics", "dimensions_items"
end
