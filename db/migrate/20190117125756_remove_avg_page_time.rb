class RemoveAvgPageTime < ActiveRecord::Migration[5.2]
  def change
    remove_column :aggregations_monthly_metrics, :avg_page_time
    remove_column :events_gas, :avg_page_time
    remove_column :facts_metrics, :avg_page_time
  end
end
