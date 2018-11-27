class UpdateAggregationsSearchLastThirtyDaysToVersion2 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_thirty_days, version: 2, revert_to_version: 1, materialized: true
  end
end
