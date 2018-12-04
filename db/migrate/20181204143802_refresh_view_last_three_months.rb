class RefreshViewLastThreeMonths < ActiveRecord::Migration[5.2]
  def change
    Aggregations::SearchLastThreeMonths.refresh
  end
end
