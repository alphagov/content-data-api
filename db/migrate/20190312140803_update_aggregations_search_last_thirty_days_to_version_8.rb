class UpdateAggregationsSearchLastThirtyDaysToVersion8 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_thirty_days,
                version: 8,
                revert_to_version: 7,
                materialized: true
  end
end
