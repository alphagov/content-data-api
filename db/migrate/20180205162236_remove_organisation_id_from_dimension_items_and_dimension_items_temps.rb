class RemoveOrganisationIdFromDimensionItemsAndDimensionItemsTemps < ActiveRecord::Migration[5.1]
  def change
    remove_column :dimensions_items, :organisation_id, :string
    remove_column :dimensions_items_temps, :organisation_id, :string
  end
end
