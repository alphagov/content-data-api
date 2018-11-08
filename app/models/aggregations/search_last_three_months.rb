class Aggregations::SearchLastThreeMonths < ApplicationRecord
  def self.refresh
    Aggregations::MaterializedView.prepare
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
