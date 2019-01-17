class RemoveBounceRate < ActiveRecord::Migration[5.2]
  def change
    remove_column :aggregations_monthly_metrics, :bounce_rate
    remove_column :events_gas, :bounce_rate
    remove_column :facts_metrics, :bounce_rate
  end
end
