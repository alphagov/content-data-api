class DropJoinTableGroupsContentItems < ActiveRecord::Migration[5.1]
  def change
    drop_join_table :groups, :content_items do |t|
      t.index [:content_item_id]
      t.index [:group_id]
      t.index [:group_id, :content_item_id], name: "index_group_content_items", unique: true
    end
  end
end
