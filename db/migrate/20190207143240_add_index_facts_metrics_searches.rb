class AddIndexFactsMetricsSearches < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :facts_metrics, %i(dimensions_date_id searches), algorithm: :concurrently
  end
end
