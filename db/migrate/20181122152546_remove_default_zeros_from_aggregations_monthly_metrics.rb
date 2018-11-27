class RemoveDefaultZerosFromAggregationsMonthlyMetrics < ActiveRecord::Migration[5.2]
  COLS = %i[pviews upviews feedex searches exits entrances bounces bounce_rate avg_page_time page_time].freeze

  def up
    COLS.each do |col|
      change_column_default(:aggregations_monthly_metrics, col, nil)
      change_column_null(:aggregations_monthly_metrics, col, true)
    end
  end

  def down
    COLS.each do |col|
      change_column_default(:aggregations_monthly_metrics, col, 0)
      change_column_null(:aggregations_monthly_metrics, col, false)
    end
  end
end
