class SetDefaultValueForNumberOfViews < ActiveRecord::Migration[5.0]
  def up
    ContentItem.update_all(number_of_views: 0)
  end
end
