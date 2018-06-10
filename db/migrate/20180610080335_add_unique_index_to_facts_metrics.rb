class AddUniqueIndexToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    remove_index :facts_metrics, name: 'index_facts_metrics_date_item_id'
    remove_index :facts_metrics, name: 'index_facts_metrics_on_dimensions_item_id'
    remove_index :facts_editions, %i[dimensions_item_id dimensions_date_id]
    add_index :facts_metrics, %i[dimensions_date_id dimensions_item_id], name: :metrics_item_id_date_id, unique: true
  end
end
