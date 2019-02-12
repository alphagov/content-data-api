class Aggregations::MaterializedView
  def self.prepare
    DatabaseHelper.increase_work_mem_for_current_transaction(megabytes: 500)
  end
end
