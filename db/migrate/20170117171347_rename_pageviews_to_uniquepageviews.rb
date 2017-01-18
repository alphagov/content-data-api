class RenamePageviewsToUniquepageviews < ActiveRecord::Migration[5.0]
  def change
    rename_column :content_items, :number_of_views, :unique_page_views
  end
end
