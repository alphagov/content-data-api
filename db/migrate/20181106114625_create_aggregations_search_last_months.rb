class CreateAggregationsSearchLastMonths < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.connection.execute("set local work_mem = '500MB'")
    create_view :aggregations_search_last_months, materialized: true
  end
end
