class RefreshViewLastMonth < ActiveRecord::Migration[5.2]
  def change
    Aggregations::SearchLastMonth.refresh
  end
end
