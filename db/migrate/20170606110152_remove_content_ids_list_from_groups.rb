class RemoveContentIdsListFromGroups < ActiveRecord::Migration[5.1]
  def change
    remove_column :groups, :content_item_ids
  end
end
