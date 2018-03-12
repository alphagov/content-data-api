class AddPrimaryOrgFieldsToDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :primary_organisation_title, :string
    add_column :dimensions_items, :primary_organisation_content_id, :string
    add_column :dimensions_items, :primary_organisation_withdrawn, :boolean
  end
end
