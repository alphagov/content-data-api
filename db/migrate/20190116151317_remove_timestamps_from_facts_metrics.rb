class RemoveTimestampsFromFactsMetrics < ActiveRecord::Migration[5.2]
  def change
    remove_column :facts_metrics, :created_at, :string
    remove_column :facts_metrics, :updated_at, :string
  end
end
