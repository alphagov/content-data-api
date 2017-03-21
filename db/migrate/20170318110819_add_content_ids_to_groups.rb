class AddContentIdsToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :content_item_ids, :text, array: true, default: []
  end
end
