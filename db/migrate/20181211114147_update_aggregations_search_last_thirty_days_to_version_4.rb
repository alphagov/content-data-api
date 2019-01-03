class UpdateAggregationsSearchLastThirtyDaysToVersion4 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_thirty_days, version: 4, revert_to_version: 3, materialized: true
  end
end
