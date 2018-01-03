class DeleteContentFromDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :content
  end
end
