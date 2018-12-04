class RefreshViewLastSixMonths < ActiveRecord::Migration[5.2]
  def change
    Aggregations::SearchLastSixMonths.refresh
  end
end
