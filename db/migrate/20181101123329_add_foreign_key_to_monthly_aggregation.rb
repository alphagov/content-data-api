class AddForeignKeyToMonthlyAggregation < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :aggregations_monthly_metrics, :dimensions_months, foreign_key: :dimensions_month_id, primary_key: :id
  end
end
