class RemoveConstraintsWarehouseItemIdLatest < ActiveRecord::Migration[5.2]
  def change
    remove_index :dimensions_editions, name: :index_dimensions_editions_on_latest_and_warehouse_item_id
  end
end
