class RemoveExpandedLinksColumn < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :expanded_links, :json
  end
end
