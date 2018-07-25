class RenameDimensionsItemsLinksColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items, :links, :expanded_links
  end
end
