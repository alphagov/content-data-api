class ChangeDimensionsItemsFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items, :link, :base_path
  end
end
