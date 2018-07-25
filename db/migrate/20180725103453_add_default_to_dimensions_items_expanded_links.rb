class AddDefaultToDimensionsItemsExpandedLinks < ActiveRecord::Migration[5.1]
  def change
    change_column_default :dimensions_items, :expanded_links, {}
  end
end
