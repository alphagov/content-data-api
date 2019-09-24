class AddIndexToLastMonthAggregations < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_search_last_months, %w(dimensions_edition_id upviews), name: "index_on_last_month_edition_id_upviews"
  end
end
