class AddIndexDimensionsItemsContentUuid < ActiveRecord::Migration[5.2]
  def change
    add_index :dimensions_items, :content_uuid, name: 'index_dimensions_items_content_uuid'
    add_index :dimensions_items, %i[content_uuid latest], name: 'index_dimensions_items_content_uuid_latest'
  end
end
