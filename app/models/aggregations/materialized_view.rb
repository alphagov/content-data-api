class Aggregations::MaterializedView < ApplicationRecord
  self.abstract_class = true

  self.primary_key = "warehouse_item_id"

  def self.prepare
    increase_work_mem_for_current_transaction
  end

  # `work_mem` speeds up the query because it is a big aggregations with sorting
  # that needs to perform the operation in memory
  # we are setting the work_mem locally, which means that will only be active
  # for the current transaction. This is a safe operation because views are only
  # refreshed once per day, and in a single thread.
  #
  # This should never be enabled globally.
  def self.increase_work_mem_for_current_transaction
    ActiveRecord::Base.connection.execute("set local work_mem = '500MB'")
  end

  def self.refresh
    prepare
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end
