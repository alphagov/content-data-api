class AddLatestToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :latest, :boolean
  end
end
