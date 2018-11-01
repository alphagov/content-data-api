class AddHistoricalConstraints < ActiveRecord::Migration[5.2]
  def up
    change_column_null :dimensions_editions, :historical, false
  end

  def down
    change_column_null :dimensions_editions, :historical, true
  end
end
