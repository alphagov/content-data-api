class AddIndexToDimensionsItemsOnLatest < ActiveRecord::Migration[5.2]
  def change
    add_index :dimensions_items, :latest
  end
end
