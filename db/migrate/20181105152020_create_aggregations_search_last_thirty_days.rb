class CreateAggregationsSearchLastThirtyDays < ActiveRecord::Migration[5.2]
  def change
    Aggregations::MaterializedView.prepare
    create_view :aggregations_search_last_thirty_days, materialized: true
  end
end
