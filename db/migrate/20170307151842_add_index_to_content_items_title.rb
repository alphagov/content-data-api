class AddIndexToContentItemsTitle < ActiveRecord::Migration[5.0]
  def change
    add_index :content_items, :title
  end
end
