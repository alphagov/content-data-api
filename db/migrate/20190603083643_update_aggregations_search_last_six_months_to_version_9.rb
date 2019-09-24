class UpdateAggregationsSearchLastSixMonthsToVersion9 < ActiveRecord::Migration[5.2]
  def change
    update_view(
      :aggregations_search_last_six_months,
      version: 9,
      revert_to_version: 8,
      materialized: true,
    )
  end
end
