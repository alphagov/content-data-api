class AddIndexesForMasterProcess < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, %i[latest content_id]
    add_index :facts_metrics, %i[dimensions_date_id dimensions_item_id], name: "index_facts_metrics_date_item_id"
  end
end
