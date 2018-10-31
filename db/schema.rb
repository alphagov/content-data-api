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

ActiveRecord::Schema.define(version: 2018_10_31_124930) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aggregations_monthly_metrics", force: :cascade do |t|
    t.string "dimensions_month_id", null: false
    t.bigint "dimensions_edition_id", null: false
    t.integer "pviews", default: 0, null: false
    t.integer "upviews", default: 0, null: false
    t.integer "feedex", default: 0, null: false
    t.integer "useful_yes", default: 0, null: false
    t.integer "useful_no", default: 0, null: false
    t.integer "searches", default: 0, null: false
    t.integer "exits", default: 0, null: false
    t.integer "entrances", default: 0, null: false
    t.integer "bounce_rate", default: 0, null: false
    t.integer "avg_page_time", default: 0, null: false
    t.integer "bounces", default: 0, null: false
    t.integer "page_time", default: 0, null: false
    t.float "satisfaction", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dimensions_edition_id", "dimensions_month_id"], name: "index_editions_months_unique", unique: true
    t.index ["dimensions_edition_id"], name: "index_aggregations_monthly_metrics_on_dimensions_edition_id"
    t.index ["dimensions_month_id"], name: "index_aggregations_monthly_metrics_on_dimensions_month_id"
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
  end

  create_table "dimensions_editions", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "title"
    t.string "base_path", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "latest"
    t.string "document_type"
    t.string "content_purpose_document_supertype"
    t.datetime "first_published_at"
    t.datetime "public_updated_at"
    t.string "primary_organisation_title"
    t.string "organisation_id"
    t.boolean "primary_organisation_withdrawn"
    t.string "locale"
    t.bigint "publishing_api_payload_version", null: false
    t.string "content_purpose_supergroup"
    t.string "content_purpose_subgroup"
    t.string "schema_name", null: false
    t.text "document_text"
    t.string "publishing_app"
    t.string "rendering_app"
    t.string "analytics_identifier"
    t.string "phase"
    t.string "previous_version"
    t.string "update_type"
    t.datetime "last_edited_at"
    t.string "warehouse_item_id", null: false
    t.json "raw_json"
    t.boolean "withdrawn", null: false
    t.boolean "historical", null: false
    t.index ["base_path"], name: "index_dimensions_editions_on_base_path"
    t.index ["content_id", "latest"], name: "index_dimensions_editions_on_content_id_and_latest"
    t.index ["latest", "base_path"], name: "index_dimensions_editions_on_latest_and_base_path", unique: true, where: "(latest = true)"
    t.index ["latest", "document_type"], name: "index_dimensions_editions_on_latest_and_document_type"
    t.index ["latest", "organisation_id", "primary_organisation_title"], name: "index_dimensions_editions_on_latest_org_id_org_title"
    t.index ["latest", "warehouse_item_id"], name: "index_dimensions_editions_on_latest_and_warehouse_item_id", unique: true, where: "(latest = true)"
    t.index ["latest"], name: "index_dimensions_editions_on_latest"
    t.index ["organisation_id"], name: "index_dimensions_editions_organisation_id"
    t.index ["warehouse_item_id", "base_path", "title", "document_type"], name: "index_for_content_query"
    t.index ["warehouse_item_id", "latest"], name: "index_dimensions_editions_warehouse_item_id_latest"
    t.index ["warehouse_item_id"], name: "index_dimensions_editions_warehouse_item_id"
  end

  create_table "dimensions_months", id: false, force: :cascade do |t|
    t.string "id", null: false
    t.string "month_name", null: false
    t.string "month_name_abbreviated", null: false
    t.integer "month_number", null: false
    t.integer "quarter", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events_feedexes", force: :cascade do |t|
    t.date "date"
    t.string "page_path"
    t.integer "feedex_comments"
    t.index ["page_path", "date"], name: "index_events_feedexes_on_page_path_and_date"
  end

  create_table "events_gas", force: :cascade do |t|
    t.date "date"
    t.string "page_path"
    t.integer "pviews", default: 0
    t.integer "upviews", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "useful_yes", default: 0
    t.integer "useful_no", default: 0
    t.integer "process_name", null: false
    t.integer "searches", default: 0
    t.integer "exits", default: 0
    t.integer "entrances", default: 0
    t.integer "bounce_rate", default: 0
    t.integer "avg_page_time", default: 0
    t.integer "bounces", default: 0
    t.integer "page_time", default: 0
    t.index ["page_path", "date"], name: "index_events_gas_on_page_path_and_date"
    t.index ["process_name", "date", "page_path"], name: "index_events_gas_on_process_name_and_date_and_page_path", unique: true
  end

  create_table "facts_editions", force: :cascade do |t|
    t.date "dimensions_date_id", null: false
    t.bigint "dimensions_edition_id", null: false
    t.integer "pdf_count"
    t.integer "doc_count"
    t.integer "readability"
    t.integer "chars"
    t.integer "sentences"
    t.integer "words"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dimensions_edition_id", "dimensions_date_id"], name: "facts_editions_edition_id_date_id", unique: true
  end

  create_table "facts_metrics", force: :cascade do |t|
    t.date "dimensions_date_id", null: false
    t.bigint "dimensions_edition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pviews", default: 0
    t.integer "upviews", default: 0
    t.integer "feedex", default: 0
    t.integer "useful_yes", default: 0, null: false
    t.integer "useful_no", default: 0, null: false
    t.integer "searches", default: 0
    t.integer "exits", default: 0
    t.integer "entrances", default: 0
    t.integer "bounce_rate", default: 0
    t.integer "avg_page_time", default: 0
    t.integer "bounces", default: 0
    t.integer "page_time", default: 0
    t.float "satisfaction", default: 0.0, null: false
    t.index ["dimensions_date_id", "dimensions_edition_id"], name: "metrics_edition_id_date_id", unique: true
    t.index ["dimensions_edition_id"], name: "index_facts_metrics_on_dimensions_edition_id"
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

  add_foreign_key "facts_editions", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_editions", "dimensions_editions"
  add_foreign_key "facts_metrics", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_metrics", "dimensions_editions"
end
