class AddContentUuidToDimensionsItem < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_items, :content_uuid, :string
  end
end
