class AddIndexDimensionsItemsLocale < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, :locale,
      name: :index_dimensions_items_locale
  end
end
