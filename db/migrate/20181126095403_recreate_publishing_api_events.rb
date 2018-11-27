class RecreatePublishingApiEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :publishing_api_events do |t|
      t.string :routing_key
      t.jsonb :payload

      t.timestamps
    end

    add_reference :dimensions_editions, :publishing_api_event, foreign_key: true, index: true
  end
end
