class UpdateAggregationsSearchLastThirtyDaysToVersion10 < ActiveRecord::Migration[5.2]
  def change
    update_view(
      :aggregations_search_last_thirty_days,
      version: 10,
      revert_to_version: 9,
      materialized: true,
    )
  end
end
