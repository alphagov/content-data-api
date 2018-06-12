class RemoveContentHashFromDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :content_hash, :string
  end
end
