class AddDirtyToDimensionItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :dirty, :boolean, default: false
  end
end
