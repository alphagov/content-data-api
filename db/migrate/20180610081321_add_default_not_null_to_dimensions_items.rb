class AddDefaultNotNullToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    change_column_null :dimensions_items, :content_id, false
    change_column_null :dimensions_items, :base_path, false
    change_column_null :dimensions_items, :schema_name, false
  end
end
