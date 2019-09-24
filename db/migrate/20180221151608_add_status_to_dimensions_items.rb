class AddStatusToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :status, :string, default: "live"
  end
end
