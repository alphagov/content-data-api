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

ActiveRecord::Schema[6.1].define(version: 2019_06_13_112120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aggregations_monthly_metrics", force: :cascade do |t|
    t.string "dimensions_month_id", null: false
    t.bigint "dimensions_edition_id", null: false
    t.integer "pviews"
    t.integer "upviews"
    t.integer "feedex"
    t.integer "useful_yes", default: 0, null: false
    t.integer "useful_no", default: 0, null: false
    t.integer "searches"
    t.integer "exits"
    t.integer "entrances"
    t.integer "bounces"
    t.integer "page_time"
    t.float "satisfaction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_aggregations_monthly_metrics_on_created_at"
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
    t.boolean "live"
    t.string "document_type", null: false
    t.datetime "first_published_at"
    t.datetime "public_updated_at"
    t.string "primary_organisation_title"
    t.string "primary_organisation_id"
    t.boolean "primary_organisation_withdrawn"
    t.string "locale", null: false
    t.bigint "publishing_api_payload_version", null: false
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
    t.boolean "withdrawn", null: false
    t.boolean "historical", null: false
    t.bigint "publishing_api_event_id"
    t.string "acronym"
    t.string "organisation_ids", default: [], array: true
    t.integer "parent_id"
    t.integer "sibling_order"
    t.string "child_sort_order", array: true
    t.index "lower((base_path)::text)", name: "index_lower_base_path"
    t.index ["base_path"], name: "index_dimensions_editions_on_base_path"
    t.index ["content_id", "live"], name: "index_dimensions_editions_on_content_id_and_live"
    t.index ["document_type"], name: "index_dimensions_editions_on_document_type"
    t.index ["live", "base_path"], name: "index_dimensions_editions_on_live_and_base_path", unique: true, where: "(live = true)"
    t.index ["live", "document_type"], name: "index_dimensions_editions_on_live_and_document_type"
    t.index ["live", "primary_organisation_id", "primary_organisation_title"], name: "index_dimensions_editions_on_latest_org_id_org_title"
    t.index ["live", "warehouse_item_id"], name: "index_dimensions_editions_on_live_and_warehouse_item_id", unique: true, where: "(live = true)"
    t.index ["live"], name: "index_dimensions_editions_on_live"
    t.index ["parent_id"], name: "index_dim_edition_parent_id"
    t.index ["primary_organisation_id"], name: "index_dimensions_editions_organisation_id"
    t.index ["publishing_api_event_id"], name: "index_dimensions_editions_on_publishing_api_event_id"
    t.index ["warehouse_item_id", "base_path", "title", "document_type"], name: "index_for_content_query"
    t.index ["warehouse_item_id", "live"], name: "index_dimensions_editions_warehouse_item_id_latest"
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
    t.index ["id"], name: "index_dimensions_months_on_id", unique: true
  end

  create_table "events_feedexes", force: :cascade do |t|
    t.date "date"
    t.string "page_path"
    t.integer "feedex_comments", default: 0
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
    t.integer "reading_time"
    t.index ["dimensions_edition_id", "dimensions_date_id"], name: "facts_editions_edition_id_date_id", unique: true
  end

  create_table "facts_metrics", force: :cascade do |t|
    t.date "dimensions_date_id", null: false
    t.bigint "dimensions_edition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pviews", default: 0, null: false
    t.integer "upviews", default: 0, null: false
    t.integer "feedex", default: 0, null: false
    t.integer "useful_yes", default: 0, null: false
    t.integer "useful_no", default: 0, null: false
    t.integer "searches", default: 0, null: false
    t.integer "exits", default: 0, null: false
    t.integer "entrances", default: 0, null: false
    t.integer "bounces", default: 0, null: false
    t.integer "page_time", default: 0, null: false
    t.float "satisfaction"
    t.index ["dimensions_date_id", "dimensions_edition_id"], name: "metrics_edition_id_date_id", unique: true
    t.index ["dimensions_date_id", "feedex"], name: "index_facts_metrics_on_dimensions_date_id_and_feedex"
    t.index ["dimensions_date_id", "pviews"], name: "index_facts_metrics_on_dimensions_date_id_and_pviews"
    t.index ["dimensions_date_id", "searches"], name: "index_facts_metrics_on_dimensions_date_id_and_searches"
    t.index ["dimensions_date_id", "upviews"], name: "index_facts_metrics_on_dimensions_date_id_and_upviews"
    t.index ["dimensions_date_id", "useful_no"], name: "index_facts_metrics_on_dimensions_date_id_and_useful_no"
    t.index ["dimensions_edition_id"], name: "index_facts_metrics_on_dimensions_edition_id"
  end

  create_table "publishing_api_events", force: :cascade do |t|
    t.string "routing_key"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  add_foreign_key "aggregations_monthly_metrics", "dimensions_months"
  add_foreign_key "dimensions_editions", "publishing_api_events"
  add_foreign_key "facts_editions", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_editions", "dimensions_editions"
  add_foreign_key "facts_metrics", "dimensions_dates", primary_key: "date"
  add_foreign_key "facts_metrics", "dimensions_editions"

  create_view "aggregations_search_last_months", materialized: true, sql_definition: <<-SQL
      SELECT dimensions_editions.warehouse_item_id,
      dimensions_editions.title,
      dimensions_editions.document_type,
      dimensions_editions.base_path,
      dimensions_editions.primary_organisation_id,
      dimensions_editions.organisation_ids,
      dimensions_editions.id AS dimensions_edition_id,
      aggregations.upviews,
      aggregations.pviews,
      aggregations.feedex,
      aggregations.useful_yes,
      aggregations.useful_no,
      CURRENT_DATE AS updated_at,
          CASE
              WHEN ((aggregations.useful_yes + aggregations.useful_no) = 0) THEN NULL::double precision
              ELSE ((aggregations.useful_yes)::double precision / ((aggregations.useful_yes + aggregations.useful_no))::double precision)
          END AS satisfaction,
      aggregations.searches,
      facts_editions.words,
      facts_editions.pdf_count,
      facts_editions.reading_time
     FROM ((( SELECT dimensions_editions_1.warehouse_item_id,
              max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
              sum(aggregations_monthly_metrics.upviews) AS upviews,
              sum(aggregations_monthly_metrics.pviews) AS pviews,
              sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
              sum(aggregations_monthly_metrics.useful_no) AS useful_no,
              sum(aggregations_monthly_metrics.feedex) AS feedex,
              sum(aggregations_monthly_metrics.searches) AS searches
             FROM ((aggregations_monthly_metrics
               JOIN dimensions_months ON (((dimensions_months.id)::text = (aggregations_monthly_metrics.dimensions_month_id)::text)))
               JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = aggregations_monthly_metrics.dimensions_edition_id)))
            WHERE ((dimensions_months.id)::text = to_char((now() - '1 mon'::interval), 'YYYY-MM'::text))
            GROUP BY dimensions_editions_1.warehouse_item_id) aggregations
       JOIN dimensions_editions ON ((aggregations.dimensions_edition_id = dimensions_editions.id)))
       JOIN facts_editions ON ((dimensions_editions.id = facts_editions.dimensions_edition_id)))
    WHERE ((dimensions_editions.document_type)::text <> ALL ((ARRAY['gone'::character varying, 'vanish'::character varying, 'need'::character varying, 'unpublishing'::character varying, 'redirect'::character varying])::text[]));
  SQL
  add_index "aggregations_search_last_months", "to_tsvector('english'::regconfig, (title)::text)", name: "aggregations_search_last_month_gin_title", using: :gin
  add_index "aggregations_search_last_months", "to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text))", name: "aggregations_search_last_month_gin_base_path", using: :gin
  add_index "aggregations_search_last_months", ["document_type", "upviews", "warehouse_item_id"], name: "search_last_month_document_type"
  add_index "aggregations_search_last_months", ["primary_organisation_id", "upviews", "warehouse_item_id"], name: "search_last_months_organisation_id"
  add_index "aggregations_search_last_months", ["upviews", "warehouse_item_id"], name: "search_last_month_upviews", order: { upviews: "DESC NULLS LAST", warehouse_item_id: :desc }
  add_index "aggregations_search_last_months", ["warehouse_item_id"], name: "aggregations_search_last_months_pk", unique: true

  create_view "aggregations_search_last_thirty_days", materialized: true, sql_definition: <<-SQL
      SELECT dimensions_editions.warehouse_item_id,
      dimensions_editions.title,
      dimensions_editions.document_type,
      dimensions_editions.base_path,
      dimensions_editions.primary_organisation_id,
      dimensions_editions.organisation_ids,
      dimensions_editions.id AS dimensions_edition_id,
      aggregations.upviews,
      aggregations.pviews,
      aggregations.feedex,
      aggregations.useful_yes,
      aggregations.useful_no,
      CURRENT_DATE AS updated_at,
          CASE
              WHEN ((aggregations.useful_yes + aggregations.useful_no) = 0) THEN NULL::double precision
              ELSE ((aggregations.useful_yes)::double precision / ((aggregations.useful_yes + aggregations.useful_no))::double precision)
          END AS satisfaction,
      aggregations.searches,
      facts_editions.words,
      facts_editions.pdf_count,
      facts_editions.reading_time
     FROM ((( SELECT dimensions_editions_1.warehouse_item_id,
              max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
              sum(facts_metrics.upviews) AS upviews,
              sum(facts_metrics.pviews) AS pviews,
              sum(facts_metrics.useful_yes) AS useful_yes,
              sum(facts_metrics.useful_no) AS useful_no,
              sum(facts_metrics.feedex) AS feedex,
              sum(facts_metrics.searches) AS searches
             FROM ((facts_metrics
               JOIN dimensions_dates ON ((dimensions_dates.date = facts_metrics.dimensions_date_id)))
               JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = facts_metrics.dimensions_edition_id)))
            WHERE ((facts_metrics.dimensions_date_id > (('yesterday'::text)::date - '30 days'::interval day)) AND (facts_metrics.dimensions_date_id < ('now'::text)::date))
            GROUP BY dimensions_editions_1.warehouse_item_id) aggregations
       JOIN dimensions_editions ON ((aggregations.dimensions_edition_id = dimensions_editions.id)))
       JOIN facts_editions ON ((dimensions_editions.id = facts_editions.dimensions_edition_id)))
    WHERE ((dimensions_editions.document_type)::text <> ALL ((ARRAY['gone'::character varying, 'vanish'::character varying, 'need'::character varying, 'unpublishing'::character varying, 'redirect'::character varying])::text[]));
  SQL
  add_index "aggregations_search_last_thirty_days", "to_tsvector('english'::regconfig, (title)::text)", name: "aggregations_search_last_thirty_days_gin_title", using: :gin
  add_index "aggregations_search_last_thirty_days", "to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text))", name: "aggregations_search_last_thirty_days_gin_base_path", using: :gin
  add_index "aggregations_search_last_thirty_days", ["document_type", "upviews", "warehouse_item_id"], name: "search_last_thirty_days_document_type"
  add_index "aggregations_search_last_thirty_days", ["primary_organisation_id", "upviews", "warehouse_item_id"], name: "search_last_thirty_days_organisation_id"
  add_index "aggregations_search_last_thirty_days", ["upviews", "warehouse_item_id"], name: "search_last_thirty_days_upviews", order: { upviews: "DESC NULLS LAST", warehouse_item_id: :desc }
  add_index "aggregations_search_last_thirty_days", ["warehouse_item_id"], name: "aggregations_search_last_thirty_days_pk", unique: true

  create_view "aggregations_search_last_three_months", materialized: true, sql_definition: <<-SQL
      SELECT dimensions_editions.warehouse_item_id,
      dimensions_editions.title,
      dimensions_editions.document_type,
      dimensions_editions.base_path,
      dimensions_editions.primary_organisation_id,
      dimensions_editions.organisation_ids,
      dimensions_editions.id AS dimensions_edition_id,
      (aggregations.upviews)::bigint AS upviews,
      (aggregations.pviews)::bigint AS pviews,
      (aggregations.feedex)::bigint AS feedex,
      (aggregations.useful_yes)::bigint AS useful_yes,
      (aggregations.useful_no)::bigint AS useful_no,
      CURRENT_DATE AS updated_at,
          CASE
              WHEN ((aggregations.useful_yes + aggregations.useful_no) = (0)::numeric) THEN NULL::double precision
              ELSE ((aggregations.useful_yes)::double precision / ((aggregations.useful_yes + aggregations.useful_no))::double precision)
          END AS satisfaction,
      (aggregations.searches)::bigint AS searches,
      facts_editions.words,
      facts_editions.pdf_count,
      facts_editions.reading_time
     FROM ((( SELECT agg.warehouse_item_id,
              max(agg.dimensions_edition_id) AS dimensions_edition_id,
              sum(agg.upviews) AS upviews,
              sum(agg.pviews) AS pviews,
              sum(agg.useful_yes) AS useful_yes,
              sum(agg.useful_no) AS useful_no,
              sum(agg.feedex) AS feedex,
              sum(agg.searches) AS searches
             FROM ( SELECT dimensions_editions_1.warehouse_item_id,
                      max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
                      sum(aggregations_monthly_metrics.upviews) AS upviews,
                      sum(aggregations_monthly_metrics.pviews) AS pviews,
                      sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
                      sum(aggregations_monthly_metrics.useful_no) AS useful_no,
                      sum(aggregations_monthly_metrics.feedex) AS feedex,
                      sum(aggregations_monthly_metrics.searches) AS searches
                     FROM ((aggregations_monthly_metrics
                       JOIN dimensions_months ON (((dimensions_months.id)::text = (aggregations_monthly_metrics.dimensions_month_id)::text)))
                       JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = aggregations_monthly_metrics.dimensions_edition_id)))
                    WHERE ((dimensions_months.id)::text >= to_char((('yesterday'::text)::date - '2 mons'::interval), 'YYYY-MM'::text))
                    GROUP BY dimensions_editions_1.warehouse_item_id
                  UNION
                   SELECT dimensions_editions_1.warehouse_item_id,
                      max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
                      sum(facts_metrics.upviews) AS upviews,
                      sum(facts_metrics.pviews) AS pviews,
                      sum(facts_metrics.useful_yes) AS useful_yes,
                      sum(facts_metrics.useful_no) AS useful_no,
                      sum(facts_metrics.feedex) AS feedex,
                      sum(facts_metrics.searches) AS searches
                     FROM ((facts_metrics
                       JOIN dimensions_dates ON ((dimensions_dates.date = facts_metrics.dimensions_date_id)))
                       JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = facts_metrics.dimensions_edition_id)))
                    WHERE ((facts_metrics.dimensions_date_id > (('yesterday'::text)::date - '3 mons'::interval)) AND (facts_metrics.dimensions_date_id < (to_char((('yesterday'::text)::date - '2 mons'::interval), 'YYYY-MM-01'::text))::date))
                    GROUP BY dimensions_editions_1.warehouse_item_id) agg
            GROUP BY agg.warehouse_item_id) aggregations
       JOIN dimensions_editions ON ((aggregations.dimensions_edition_id = dimensions_editions.id)))
       JOIN facts_editions ON ((dimensions_editions.id = facts_editions.dimensions_edition_id)))
    WHERE ((dimensions_editions.document_type)::text <> ALL ((ARRAY['gone'::character varying, 'vanish'::character varying, 'need'::character varying, 'unpublishing'::character varying, 'redirect'::character varying])::text[]));
  SQL
  add_index "aggregations_search_last_three_months", "to_tsvector('english'::regconfig, (title)::text)", name: "aggregations_search_last_three_months_gin_title", using: :gin
  add_index "aggregations_search_last_three_months", "to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text))", name: "aggregations_search_last_three_months_gin_base_path", using: :gin
  add_index "aggregations_search_last_three_months", ["document_type", "upviews", "warehouse_item_id"], name: "search_last_three_months_document_type"
  add_index "aggregations_search_last_three_months", ["primary_organisation_id", "upviews", "warehouse_item_id"], name: "search_last_three_months_organisation_id"
  add_index "aggregations_search_last_three_months", ["upviews", "warehouse_item_id"], name: "search_last_three_months_upviews", order: { upviews: "DESC NULLS LAST", warehouse_item_id: :desc }
  add_index "aggregations_search_last_three_months", ["warehouse_item_id"], name: "aggregations_search_last_three_months_pk", unique: true

  create_view "aggregations_search_last_twelve_months", materialized: true, sql_definition: <<-SQL
      SELECT dimensions_editions.warehouse_item_id,
      dimensions_editions.title,
      dimensions_editions.document_type,
      dimensions_editions.base_path,
      dimensions_editions.primary_organisation_id,
      dimensions_editions.organisation_ids,
      dimensions_editions.id AS dimensions_edition_id,
      (aggregations.upviews)::bigint AS upviews,
      (aggregations.pviews)::bigint AS pviews,
      (aggregations.feedex)::bigint AS feedex,
      (aggregations.useful_yes)::bigint AS useful_yes,
      (aggregations.useful_no)::bigint AS useful_no,
      CURRENT_DATE AS updated_at,
          CASE
              WHEN ((aggregations.useful_yes + aggregations.useful_no) = (0)::numeric) THEN NULL::double precision
              ELSE ((aggregations.useful_yes)::double precision / ((aggregations.useful_yes + aggregations.useful_no))::double precision)
          END AS satisfaction,
      (aggregations.searches)::bigint AS searches,
      facts_editions.words,
      facts_editions.pdf_count,
      facts_editions.reading_time
     FROM ((( SELECT agg.warehouse_item_id,
              max(agg.dimensions_edition_id) AS dimensions_edition_id,
              sum(agg.upviews) AS upviews,
              sum(agg.pviews) AS pviews,
              sum(agg.useful_yes) AS useful_yes,
              sum(agg.useful_no) AS useful_no,
              sum(agg.feedex) AS feedex,
              sum(agg.searches) AS searches
             FROM ( SELECT dimensions_editions_1.warehouse_item_id,
                      max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
                      sum(aggregations_monthly_metrics.upviews) AS upviews,
                      sum(aggregations_monthly_metrics.pviews) AS pviews,
                      sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
                      sum(aggregations_monthly_metrics.useful_no) AS useful_no,
                      sum(aggregations_monthly_metrics.feedex) AS feedex,
                      sum(aggregations_monthly_metrics.searches) AS searches
                     FROM ((aggregations_monthly_metrics
                       JOIN dimensions_months ON (((dimensions_months.id)::text = (aggregations_monthly_metrics.dimensions_month_id)::text)))
                       JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = aggregations_monthly_metrics.dimensions_edition_id)))
                    WHERE ((dimensions_months.id)::text >= to_char((('yesterday'::text)::date - '11 mons'::interval), 'YYYY-MM'::text))
                    GROUP BY dimensions_editions_1.warehouse_item_id
                  UNION
                   SELECT dimensions_editions_1.warehouse_item_id,
                      max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
                      sum(facts_metrics.upviews) AS upviews,
                      sum(facts_metrics.pviews) AS pviews,
                      sum(facts_metrics.useful_yes) AS useful_yes,
                      sum(facts_metrics.useful_no) AS useful_no,
                      sum(facts_metrics.feedex) AS feedex,
                      sum(facts_metrics.searches) AS searches
                     FROM ((facts_metrics
                       JOIN dimensions_dates ON ((dimensions_dates.date = facts_metrics.dimensions_date_id)))
                       JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = facts_metrics.dimensions_edition_id)))
                    WHERE ((facts_metrics.dimensions_date_id > (('yesterday'::text)::date - '1 year'::interval)) AND (facts_metrics.dimensions_date_id < (to_char((('yesterday'::text)::date - '11 mons'::interval), 'YYYY-MM-01'::text))::date))
                    GROUP BY dimensions_editions_1.warehouse_item_id) agg
            GROUP BY agg.warehouse_item_id) aggregations
       JOIN dimensions_editions ON ((aggregations.dimensions_edition_id = dimensions_editions.id)))
       JOIN facts_editions ON ((dimensions_editions.id = facts_editions.dimensions_edition_id)))
    WHERE ((dimensions_editions.document_type)::text <> ALL ((ARRAY['gone'::character varying, 'vanish'::character varying, 'need'::character varying, 'unpublishing'::character varying, 'redirect'::character varying])::text[]));
  SQL
  add_index "aggregations_search_last_twelve_months", "to_tsvector('english'::regconfig, (title)::text)", name: "aggregations_search_last_twelve_months_gin_title", using: :gin
  add_index "aggregations_search_last_twelve_months", "to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text))", name: "aggregations_search_last_twelve_months_gin_base_path", using: :gin
  add_index "aggregations_search_last_twelve_months", ["document_type", "upviews", "warehouse_item_id"], name: "search_last_twelve_months_document_type"
  add_index "aggregations_search_last_twelve_months", ["primary_organisation_id", "upviews", "warehouse_item_id"], name: "search_last_twelve_months_organisation_id"
  add_index "aggregations_search_last_twelve_months", ["upviews", "warehouse_item_id"], name: "search_last_twelve_months_upviews", order: { upviews: "DESC NULLS LAST", warehouse_item_id: :desc }
  add_index "aggregations_search_last_twelve_months", ["warehouse_item_id"], name: "aggregations_search_last_twelve_months_pk", unique: true

  create_view "aggregations_search_last_six_months", materialized: true, sql_definition: <<-SQL
      SELECT dimensions_editions.warehouse_item_id,
      dimensions_editions.title,
      dimensions_editions.document_type,
      dimensions_editions.base_path,
      dimensions_editions.primary_organisation_id,
      dimensions_editions.organisation_ids,
      dimensions_editions.id AS dimensions_edition_id,
      (aggregations.upviews)::bigint AS upviews,
      (aggregations.pviews)::bigint AS pviews,
      (aggregations.feedex)::bigint AS feedex,
      (aggregations.useful_yes)::bigint AS useful_yes,
      (aggregations.useful_no)::bigint AS useful_no,
      CURRENT_DATE AS updated_at,
          CASE
              WHEN ((aggregations.useful_yes + aggregations.useful_no) = (0)::numeric) THEN NULL::double precision
              ELSE ((aggregations.useful_yes)::double precision / ((aggregations.useful_yes + aggregations.useful_no))::double precision)
          END AS satisfaction,
      (aggregations.searches)::bigint AS searches,
      facts_editions.words,
      facts_editions.pdf_count,
      facts_editions.reading_time
     FROM ((( SELECT agg.warehouse_item_id,
              max(agg.dimensions_edition_id) AS dimensions_edition_id,
              sum(agg.upviews) AS upviews,
              sum(agg.pviews) AS pviews,
              sum(agg.useful_yes) AS useful_yes,
              sum(agg.useful_no) AS useful_no,
              sum(agg.feedex) AS feedex,
              sum(agg.searches) AS searches
             FROM ( SELECT dimensions_editions_1.warehouse_item_id,
                      max(aggregations_monthly_metrics.dimensions_edition_id) AS dimensions_edition_id,
                      sum(aggregations_monthly_metrics.upviews) AS upviews,
                      sum(aggregations_monthly_metrics.pviews) AS pviews,
                      sum(aggregations_monthly_metrics.useful_yes) AS useful_yes,
                      sum(aggregations_monthly_metrics.useful_no) AS useful_no,
                      sum(aggregations_monthly_metrics.feedex) AS feedex,
                      sum(aggregations_monthly_metrics.searches) AS searches
                     FROM ((aggregations_monthly_metrics
                       JOIN dimensions_months ON (((dimensions_months.id)::text = (aggregations_monthly_metrics.dimensions_month_id)::text)))
                       JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = aggregations_monthly_metrics.dimensions_edition_id)))
                    WHERE ((dimensions_months.id)::text >= to_char((('yesterday'::text)::date - '5 mons'::interval), 'YYYY-MM'::text))
                    GROUP BY dimensions_editions_1.warehouse_item_id
                  UNION
                   SELECT dimensions_editions_1.warehouse_item_id,
                      max(facts_metrics.dimensions_edition_id) AS dimensions_edition_id,
                      sum(facts_metrics.upviews) AS upviews,
                      sum(facts_metrics.pviews) AS pviews,
                      sum(facts_metrics.useful_yes) AS useful_yes,
                      sum(facts_metrics.useful_no) AS useful_no,
                      sum(facts_metrics.feedex) AS feedex,
                      sum(facts_metrics.searches) AS searches
                     FROM ((facts_metrics
                       JOIN dimensions_dates ON ((dimensions_dates.date = facts_metrics.dimensions_date_id)))
                       JOIN dimensions_editions dimensions_editions_1 ON ((dimensions_editions_1.id = facts_metrics.dimensions_edition_id)))
                    WHERE ((facts_metrics.dimensions_date_id > (('yesterday'::text)::date - '6 mons'::interval)) AND (facts_metrics.dimensions_date_id < (to_char((('yesterday'::text)::date - '5 mons'::interval), 'YYYY-MM-01'::text))::date))
                    GROUP BY dimensions_editions_1.warehouse_item_id) agg
            GROUP BY agg.warehouse_item_id) aggregations
       JOIN dimensions_editions ON ((aggregations.dimensions_edition_id = dimensions_editions.id)))
       JOIN facts_editions ON ((dimensions_editions.id = facts_editions.dimensions_edition_id)))
    WHERE ((dimensions_editions.document_type)::text <> ALL ((ARRAY['gone'::character varying, 'vanish'::character varying, 'need'::character varying, 'unpublishing'::character varying, 'redirect'::character varying])::text[]));
  SQL
  add_index "aggregations_search_last_six_months", "to_tsvector('english'::regconfig, (title)::text)", name: "aggregations_search_last_six_months_gin_title", using: :gin
  add_index "aggregations_search_last_six_months", "to_tsvector('english'::regconfig, replace((base_path)::text, '/'::text, ' '::text))", name: "aggregations_search_last_six_months_gin_base_path", using: :gin
  add_index "aggregations_search_last_six_months", ["document_type", "upviews", "warehouse_item_id"], name: "search_last_six_months_document_type"
  add_index "aggregations_search_last_six_months", ["primary_organisation_id", "upviews", "warehouse_item_id"], name: "search_last_six_months_organisation_id"
  add_index "aggregations_search_last_six_months", ["upviews", "warehouse_item_id"], name: "search_last_six_months_upviews", order: { upviews: "DESC NULLS LAST", warehouse_item_id: :desc }
  add_index "aggregations_search_last_six_months", ["warehouse_item_id"], name: "aggregations_search_last_six_months_pk", unique: true

end
