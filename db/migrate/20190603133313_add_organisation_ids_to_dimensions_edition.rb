class AddOrganisationIdsToDimensionsEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :dimensions_editions, :organisation_ids, :string, array: true, default: []
  end
end
