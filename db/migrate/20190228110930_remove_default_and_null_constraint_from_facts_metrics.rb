class RemoveDefaultAndNullConstraintFromFactsMetrics < ActiveRecord::Migration[5.2]
  def change
    change_column_default :facts_metrics, :satisfaction, nil
    change_column_null :facts_metrics, :satisfaction, true
  end
end
