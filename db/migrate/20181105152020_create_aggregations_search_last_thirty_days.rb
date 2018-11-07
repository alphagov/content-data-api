class CreateAggregationsSearchLastThirtyDays < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute("set local work_mem = '500MB'")
    create_view :aggregations_search_last_thirty_days, materialized: true
  end
end
