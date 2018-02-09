class AddRawJsonToDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :raw_json, :json
  end
end
