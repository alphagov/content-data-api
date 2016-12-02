class AddPublicUpdatedAtToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :public_updated_at, :datetime
  end
end
