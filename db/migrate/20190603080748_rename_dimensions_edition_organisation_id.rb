class RenameDimensionsEditionOrganisationId < ActiveRecord::Migration[5.2]
  def up
    rename_column :dimensions_editions, :organisation_id, :primary_organisation_id
  end

  def down
    rename_column :dimensions_editions, :primary_organisation_id, :organisation_id
  end
end
