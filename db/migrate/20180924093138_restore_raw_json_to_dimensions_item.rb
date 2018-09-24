class RestoreRawJsonToDimensionsItem < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_items, :raw_json, :json
  end
end
