class AddNotNullConstraintToFactsMetrics < ActiveRecord::Migration[5.2]
  COLS = %i[pviews upviews feedex searches exits entrances bounce_rate avg_page_time bounces page_time].freeze

  def up
    COLS.each do |col|
      change_column_null :facts_metrics, col, false
      change_column_default :facts_metrics, col, 0
    end
  end

  def down
    COLS.each do |col|
      change_column_null :facts_metrics, col, true
      change_column_default :facts_metrics, col, nil
    end
  end
end
