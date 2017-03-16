class RenamePageViewsToOneMonthPageViews < ActiveRecord::Migration[5.0]
  def change
    rename_column :content_items, :unique_page_views, :one_month_page_views
  end
end
