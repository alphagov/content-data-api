class UpdateAggregationsSearchLastSixMonthsToVersion3 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_six_months, version: 3, revert_to_version: 2, materialized: true
  end
end
