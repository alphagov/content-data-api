class AddPublishingAppToContentItem < ActiveRecord::Migration[5.1]
  def change
    add_column :content_items, :publishing_app, :string
  end
end
