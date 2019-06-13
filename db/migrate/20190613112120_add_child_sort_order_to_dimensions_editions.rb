class AddChildSortOrderToDimensionsEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_editions, :child_sort_order, :string, array: true
  end
end
