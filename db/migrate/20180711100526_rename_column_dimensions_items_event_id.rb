class RenameColumnDimensionsItemsEventId < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items, :publishing_api_events_id, :publishing_api_event_id
  end
end
