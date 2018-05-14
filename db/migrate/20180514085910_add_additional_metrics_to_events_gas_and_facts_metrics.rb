class AddAdditionalMetricsToEventsGasAndFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :events_gas, :exits, :integer, default: 0
    add_column :events_gas, :entrances, :integer, default: 0
    add_column :events_gas, :bounce_rate, :integer, default: 0
    add_column :events_gas, :avg_time_on_page, :integer, default: 0
    add_column :facts_metrics, :exits, :integer, default: 0
    add_column :facts_metrics, :entrances, :integer, default: 0
    add_column :facts_metrics, :bounce_rate, :integer, default: 0
    add_column :facts_metrics, :avg_time_on_page, :integer, default: 0
  end
end
