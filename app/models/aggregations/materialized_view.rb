class Aggregations::MaterializedView
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
end
