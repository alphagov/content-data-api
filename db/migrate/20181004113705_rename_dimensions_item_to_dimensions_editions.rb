class RenameDimensionsItemToDimensionsEditions < ActiveRecord::Migration[5.2]
  def change
    rename_table :dimensions_items, :dimensions_editions

    rename_index :dimensions_editions, 'index_dimensions_items_primary_organisation_content_id', 'index_dimensions_editions_organisation_id'
    rename_index :dimensions_editions, 'index_dimensions_items_warehouse_item_id_latest', 'index_dimensions_editions_warehouse_item_id_latest'
    rename_index :dimensions_editions, 'index_dimensions_items_warehouse_item_id', 'index_dimensions_editions_warehouse_item_id'
  end
end
