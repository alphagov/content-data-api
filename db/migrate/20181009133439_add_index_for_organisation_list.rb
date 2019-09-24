class AddIndexForOrganisationList < ActiveRecord::Migration[5.2]
  def change
    add_index :dimensions_editions, %i[latest organisation_id primary_organisation_title],
              name: "index_dimensions_editions_on_latest_org_id_org_title"
  end
end
