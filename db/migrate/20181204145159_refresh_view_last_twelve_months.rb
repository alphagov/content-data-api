class RefreshViewLastTwelveMonths < ActiveRecord::Migration[5.2]
  def change
    Aggregations::SearchLastTwelveMonths.refresh
  end
end
