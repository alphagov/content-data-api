class CreatePublishingApiEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :publishing_api_events do |t|
      t.string :routing_key
      t.jsonb :payload

      t.timestamps
    end
  end
end
