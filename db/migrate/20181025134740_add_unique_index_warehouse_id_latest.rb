class AddUniqueIndexWarehouseIdLatest < ActiveRecord::Migration[5.2]
  def change
    add_index :dimensions_editions, %i(latest warehouse_item_id), unique: true, where: "latest = 'true'"
  end
end
