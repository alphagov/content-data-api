class ChangeDimensionsItemsFields < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :base_path, :string
  end
end
