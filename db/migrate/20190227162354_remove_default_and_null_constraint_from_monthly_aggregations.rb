class RemoveDefaultAndNullConstraintFromMonthlyAggregations < ActiveRecord::Migration[5.2]
  def change
    change_column_default :aggregations_monthly_metrics, :satisfaction, nil
    change_column_null :aggregations_monthly_metrics, :satisfaction, true
  end
end
