class RemoveDefaultValuesForLocaleInItems < ActiveRecord::Migration[5.1]
  def change
    change_column(:dimensions_items, :locale, :string, null: true)
    change_column_default :dimensions_items, :locale, nil
  end
end
