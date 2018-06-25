class AddContentToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :content, :text
  end
end
