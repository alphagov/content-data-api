class AddIndexToMonthlyAggregationCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_monthly_metrics, :created_at
  end
end
