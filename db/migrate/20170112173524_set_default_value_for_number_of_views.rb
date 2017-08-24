class SetDefaultValueForNumberOfViews < ActiveRecord::Migration[5.0]
  def up
    execute "UPDATE content_items SET number_of_views = 0;"
  end
end
