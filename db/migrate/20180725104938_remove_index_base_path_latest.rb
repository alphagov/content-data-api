class RemoveIndexBasePathLatest < ActiveRecord::Migration[5.1]
  def change
    remove_index :dimensions_items, name: 'index_dimensions_items_on_base_path_and_latest'
  end
end
