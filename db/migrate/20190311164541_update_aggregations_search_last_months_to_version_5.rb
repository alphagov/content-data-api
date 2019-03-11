class UpdateAggregationsSearchLastMonthsToVersion5 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_months,
      version: 5,
      revert_to_version: 4,
      materialized: true
  end
end
