class AddNumberOfViewsToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :number_of_views, :integer, default: 0
  end
end
