class RenameEventsGasColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :events_gas, :number_of_internal_searches, :searches
    rename_column :events_gas, :pageviews, :pviews
    rename_column :events_gas, :unique_pageviews, :upviews
    rename_column :events_gas, :is_this_useful_yes, :useful_yes
    rename_column :events_gas, :is_this_useful_no, :useful_no
    rename_column :events_gas, :avg_time_on_page, :avg_page_time
    rename_column :events_gas, :time_on_page, :page_time
  end
end
