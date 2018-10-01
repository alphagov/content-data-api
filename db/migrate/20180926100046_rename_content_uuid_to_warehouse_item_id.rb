class RenameContentUuidToWarehouseItemId < ActiveRecord::Migration[5.2]
  def change
    rename_column :dimensions_items, :content_uuid, :warehouse_item_id

    rename_index :dimensions_items, 'index_dimensions_items_content_uuid_latest', 'index_dimensions_items_warehouse_item_id_latest'
    rename_index :dimensions_items, 'index_dimensions_items_content_uuid', 'index_dimensions_items_warehouse_item_id'
  end
end
