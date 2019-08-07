class UpdateAggregationsSearchLastThreeMonthsToVersion4 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_three_months,
                version: 4,
                revert_to_version: 3,
                materialized: true
  end
end
