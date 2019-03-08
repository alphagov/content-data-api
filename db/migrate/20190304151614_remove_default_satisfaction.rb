class RemoveDefaultSatisfaction < ActiveRecord::Migration[5.2]
  def up
    change_column :facts_metrics, :satisfaction, :float, null: true
    change_column_default :facts_metrics, :satisfaction, nil

    change_column :aggregations_monthly_metrics, :satisfaction, :float, null: true
    change_column_default :aggregations_monthly_metrics, :satisfaction, nil
  end

  def down
    change_column :facts_metrics, :satisfaction, :float, null: false
    change_column_default :facts_metrics, :satisfaction, 0.0

    change_column :aggregations_monthly_metrics, :satisfaction, :float, null: false
    change_column_default :aggregations_monthly_metrics, :satisfaction, 0.0
  end
end
