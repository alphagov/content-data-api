class AddSchemaNameToDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :schema_name, :string
  end
end
