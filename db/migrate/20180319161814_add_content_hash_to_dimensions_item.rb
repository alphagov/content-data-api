class AddContentHashToDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :content_hash, :string
  end
end
