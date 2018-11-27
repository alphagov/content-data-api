class RemoveRawJsonFromDimensionEditions < ActiveRecord::Migration[5.2]
  def change
    remove_column :dimensions_editions, :raw_json
  end
end
