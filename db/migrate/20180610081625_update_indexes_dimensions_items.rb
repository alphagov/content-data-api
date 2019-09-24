class UpdateIndexesDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    remove_index :dimensions_items, %i(latest base_path)
    add_index :dimensions_items, %i(base_path latest), unique: true, where: "latest = 'true'"

    remove_index :dimensions_items, name: "index_dimensions_items_on_latest_and_content_id"
    add_index :dimensions_items, %i(content_id latest)
  end
end
