class CreateAggregationsSearchLastThreeMonths < ActiveRecord::Migration[5.2]
  def change
    Aggregations::MaterializedView.prepare
    create_view :aggregations_search_last_three_months, materialized: true
  end
end
