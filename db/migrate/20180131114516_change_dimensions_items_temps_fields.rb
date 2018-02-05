class ChangeDimensionsItemsTempsFields < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items_temps, :link, :base_path
  end
end
