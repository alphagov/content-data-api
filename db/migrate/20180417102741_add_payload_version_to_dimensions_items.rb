class AddPayloadVersionToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :publishing_api_payload_version, :bigint, default: 0, null: false
    change_column_default :dimensions_items, :publishing_api_payload_version, nil
  end
end
