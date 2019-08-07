class UpdateAggregationsSearchLastThreeMonthsToVersion6 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_three_months,
                version: 6,
                revert_to_version: 5,
                materialized: true
  end
end
