class AddIndexFactsMetricsUsefulNo < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :facts_metrics, %i(dimensions_date_id useful_no), algorithm: :concurrently
  end
end
