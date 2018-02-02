class ChangeDimensionsItemsTempsFields < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items_temps, :base_path, :string
  end
end
