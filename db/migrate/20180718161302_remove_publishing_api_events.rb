class RemovePublishingApiEvents < ActiveRecord::Migration[5.1]
  def change
    remove_reference :dimensions_items, :publishing_api_event, foreign_key: true

    drop_table :publishing_api_events do |t|
      t.string :routing_key
      t.json :payload

      t.timestamps
    end
  end
end
