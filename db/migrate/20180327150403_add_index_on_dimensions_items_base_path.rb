class AddIndexOnDimensionsItemsBasePath < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, [:base_path], name: 'index_dimensions_items_on_base_path'
  end
end
