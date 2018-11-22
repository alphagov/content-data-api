class RemoveDefaultZerosFromFactsMetrics < ActiveRecord::Migration[5.2]
  COLS = %i[pviews upviews searches feedex exits entrances bounces bounce_rate avg_page_time page_time]

  def up
    COLS.each do |col|
      change_column_default(:facts_metrics, col, nil)
    end
  end

  def down
    COLS.each do |col|
      change_column_default(:facts_metrics, col, 0)
    end
  end
end
