class AddIndexToAggregationsUpviews < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_search_last_thirty_days, :upviews
    add_index :aggregations_search_last_months, :upviews
    add_index :aggregations_search_last_three_months, :upviews
    add_index :aggregations_search_last_six_months, :upviews
    add_index :aggregations_search_last_twelve_months, :upviews
  end
end
