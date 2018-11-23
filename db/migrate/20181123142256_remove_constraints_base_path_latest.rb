class RemoveConstraintsBasePathLatest < ActiveRecord::Migration[5.2]
  def change
    remove_index :dimensions_editions, name: :index_dimensions_editions_on_latest_and_base_path
  end
end
