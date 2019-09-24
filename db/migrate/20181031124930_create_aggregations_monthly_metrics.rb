class CreateAggregationsMonthlyMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :aggregations_monthly_metrics do |t|
      t.string :dimensions_month_id, null: false
      t.references :dimensions_edition, null: false

      t.integer :pviews, null: false, default: 0
      t.integer :upviews, null: false, default: 0
      t.integer :feedex, null: false, default: 0
      t.integer :useful_yes, null: false, default: 0
      t.integer :useful_no, null: false, default: 0
      t.integer :searches, null: false, default: 0
      t.integer :exits, null: false, default: 0
      t.integer :entrances, null: false, default: 0
      t.integer :bounce_rate, null: false, default: 0
      t.integer :avg_page_time, null: false, default: 0
      t.integer :bounces, null: false, default: 0
      t.integer :page_time, null: false, default: 0
      t.float :satisfaction, null: false, default: 0.0

      t.timestamps

      t.index %w[dimensions_month_id]
      t.index %w[dimensions_edition_id dimensions_month_id], name: "index_editions_months_unique", unique: true
    end
  end
end
