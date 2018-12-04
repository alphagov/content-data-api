class RefreshViewLastThirtyDays < ActiveRecord::Migration[5.2]
  def change
    Aggregations::SearchLastThirtyDays.refresh
  end
end
