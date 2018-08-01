class AddBouncesAndTimeOnPageToEventsGasAndFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :events_gas, :bounces, :integer, default: 0
    add_column :events_gas, :time_on_page, :integer, default: 0
    add_column :facts_metrics, :bounces, :integer, default: 0
    add_column :facts_metrics, :time_on_page, :integer, default: 0
  end
end
