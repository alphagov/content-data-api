class AddIndexToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_index :content_items, :content_id, unique: true
  end
end
