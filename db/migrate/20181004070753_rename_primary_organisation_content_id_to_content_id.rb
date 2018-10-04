class RenamePrimaryOrganisationContentIdToContentId < ActiveRecord::Migration[5.2]
  def change
    rename_column :dimensions_items, :primary_organisation_content_id, :organisation_id
  end
end
