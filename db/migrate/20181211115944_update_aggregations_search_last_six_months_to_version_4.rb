class UpdateAggregationsSearchLastSixMonthsToVersion4 < ActiveRecord::Migration[5.2]
  def change
    update_view :aggregations_search_last_six_months,
      version: 4,
      revert_to_version: 3,
      materialized: true
  end
end
