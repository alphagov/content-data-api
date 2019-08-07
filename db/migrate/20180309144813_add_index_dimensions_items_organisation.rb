class AddIndexDimensionsItemsOrganisation < ActiveRecord::Migration[5.1]
  def change
    add_index :dimensions_items, :primary_organisation_content_id,
              name: :index_dimensions_items_primary_organisation_content_id
  end
end
