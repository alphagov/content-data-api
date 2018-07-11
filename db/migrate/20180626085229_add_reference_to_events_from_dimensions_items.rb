class AddReferenceToEventsFromDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_reference :dimensions_items, :publishing_api_events, foreign_key: true
  end
end
