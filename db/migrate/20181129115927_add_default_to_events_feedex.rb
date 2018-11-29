class AddDefaultToEventsFeedex < ActiveRecord::Migration[5.2]
  def change
    change_column_default :events_feedexes, :feedex_comments, from: nil, to: 0
  end
end
