class AddIndexOnBasePathToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, :base_path
  end
end
