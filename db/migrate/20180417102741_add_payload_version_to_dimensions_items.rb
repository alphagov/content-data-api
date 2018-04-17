class AddPayloadVersionToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :publishing_api_payload_version, :bigint
  end
end
