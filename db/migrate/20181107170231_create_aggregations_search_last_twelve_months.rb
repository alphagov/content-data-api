class CreateAggregationsSearchLastTwelveMonths < ActiveRecord::Migration[5.2]
  def change
    create_view :aggregations_search_last_twelve_months, materialized: true
  end
end
