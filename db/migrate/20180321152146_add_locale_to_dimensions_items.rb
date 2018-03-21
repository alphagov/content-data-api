class AddLocaleToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :locale, :string
  end
end
