class AddAcronymToDimensionsEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_editions, :acronym, :string
  end
end
