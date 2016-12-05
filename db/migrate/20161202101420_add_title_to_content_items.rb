class AddTitleToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :title, :string
  end
end
