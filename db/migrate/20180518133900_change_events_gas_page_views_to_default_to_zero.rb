class ChangeEventsGasPageViewsToDefaultToZero < ActiveRecord::Migration[5.1]
  def up
    change_column :events_gas, :pageviews, :integer, default: 0
    change_column :events_gas, :unique_pageviews, :integer, default: 0
  end

  def down
    change_column :events_gas, :pageviews, :integer, default: nil
    change_column :events_gas, :unique_pageviews, :integer, default: nil
  end
end
