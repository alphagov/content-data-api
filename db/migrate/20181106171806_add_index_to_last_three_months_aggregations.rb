class AddIndexToLastThreeMonthsAggregations < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_search_last_three_months, %w(dimensions_edition_id upviews), name: "index_on_last_three_months_edition_id_upviews"
  end
end
