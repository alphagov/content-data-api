class RemoveRawJsonFromDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :raw_json, :json
  end
end
