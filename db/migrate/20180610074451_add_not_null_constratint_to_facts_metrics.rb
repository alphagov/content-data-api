class AddNotNullConstratintToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    change_column_null :facts_metrics, :dimensions_item_id, false
    change_column_null :facts_metrics, :dimensions_date_id, false
  end
end
