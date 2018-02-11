class AddIndexDimensionItemsLatesBasePath < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, %i(latest base_path)
  end
end
