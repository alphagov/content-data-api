class AddUniqueIndexOnLatestBasepath < ActiveRecord::Migration[5.2]
  def change
    add_index :dimensions_editions, %i(latest base_path), unique: true, where: "latest = 'true'"
  end
end
