class RemoveDefaultZerosFromEventsGas < ActiveRecord::Migration[5.2]
  COLS = %i[pviews upviews searches exits entrances bounces bounce_rate avg_page_time page_time].freeze

  def up
    COLS.each do |col|
      change_column_default(:events_gas, col, nil)
    end
  end

  def down
    COLS.each do |col|
      change_column_default(:events_gas, col, 0)
    end
  end
end
