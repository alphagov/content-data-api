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

ActiveRecord::Schema.define(version: 20170316163752) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "content_items", force: :cascade do |t|
    t.string   "content_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "public_updated_at"
    t.string   "base_path"
    t.string   "title"
    t.string   "document_type"
    t.string   "description"
    t.integer  "unique_page_views", default: 0
    t.integer  "number_of_pdfs",    default: 0
    t.index ["content_id"], name: "index_content_items_on_content_id", unique: true, using: :btree
    t.index ["title"], name: "index_content_items_on_title", using: :btree
  end

  create_table "content_items_organisations", id: false, force: :cascade do |t|
    t.integer "content_item_id", null: false
    t.integer "organisation_id", null: false
  end

  create_table "content_items_taxonomies", id: false, force: :cascade do |t|
    t.integer "content_item_id", null: false
    t.integer "taxonomy_id",     null: false
    t.index ["content_item_id"], name: "index_content_items_taxonomies_on_content_item_id", using: :btree
    t.index ["taxonomy_id", "content_item_id"], name: "index_content_item_taxonomies", unique: true, using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "slug"
    t.string   "name"
    t.string   "group_type"
    t.integer  "parent_group_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "organisations", force: :cascade do |t|
    t.string   "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "title"
    t.index ["slug"], name: "index_organisations_on_slug", unique: true, using: :btree
  end

  create_table "taxonomies", force: :cascade do |t|
    t.string   "content_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
