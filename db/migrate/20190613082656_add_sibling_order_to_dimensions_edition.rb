class AddSiblingOrderToDimensionsEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_editions, :sibling_order, :integer, null: true
  end
end
