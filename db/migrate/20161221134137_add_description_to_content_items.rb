class AddDescriptionToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :description, :string
  end
end
