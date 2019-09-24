class DropIndexesCreatedWithoutMigration < ActiveRecord::Migration[5.1]
  def up
    if index_exists?(:dimensions_items, %i[latest content_id], name: "idx_latest_content_id")
      remove_index :dimensions_items, name: "idx_latest_content_id"
    end

    if index_exists?(:facts_metrics, %i[dimensions_date_id dimensions_item_id], name: "idx_facts_metrics_on_dimensions_date_id_dimensios_items_id")
      remove_index :facts_metrics, name: "idx_facts_metrics_on_dimensions_date_id_dimensios_items_id"
    end
  end
end
