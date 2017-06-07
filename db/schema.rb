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

ActiveRecord::Schema.define(version: 20170706143916) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audits", id: :serial, force: :cascade do |t|
    t.string "content_id", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["content_id"], name: "index_content_items_on_content_id", unique: true
    t.index ["title"], name: "index_content_items_on_title"
  end

  create_table "content_items_groups", id: false, force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "content_item_id", null: false
    t.index ["content_item_id"], name: "index_content_items_groups_on_content_item_id"
    t.index ["group_id", "content_item_id"], name: "index_group_content_items", unique: true
    t.index ["group_id"], name: "index_content_items_groups_on_group_id"
  end

  create_table "content_items_organisations", id: false, force: :cascade do |t|
    t.bigint "content_item_id", null: false
    t.bigint "organisation_id", null: false
  end

  create_table "content_items_taxons", id: false, force: :cascade do |t|
    t.bigint "content_item_id", null: false
    t.bigint "taxon_id", null: false
    t.index ["content_item_id"], name: "index_content_items_taxons_on_content_item_id"
    t.index ["taxon_id", "content_item_id"], name: "index_content_item_taxonomies", unique: true
  end

  create_table "content_items_terms", id: false, force: :cascade do |t|
    t.bigint "term_id", null: false
    t.bigint "content_item_id", null: false
    t.index ["content_item_id"], name: "index_content_items_terms_on_content_item_id"
    t.index ["term_id", "content_item_id"], name: "index_terms_content_items", unique: true
    t.index ["term_id"], name: "index_content_items_terms_on_term_id"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.string "name"
    t.string "group_type"
    t.integer "parent_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "organisations", id: :serial, force: :cascade do |t|
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "content_id"
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.string "type", null: false
    t.text "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_questions_on_type"
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
    t.index ["content_item_id"], name: "index_taxonomy_todos_on_content_item_id"
    t.index ["taxonomy_project_id"], name: "index_taxonomy_todos_on_taxonomy_project_id"
  end

  create_table "taxons", id: :serial, force: :cascade do |t|
    t.string "content_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "terms", force: :cascade do |t|
    t.string "name"
    t.bigint "taxonomy_project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["taxonomy_project_id"], name: "index_terms_on_taxonomy_project_id"
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
