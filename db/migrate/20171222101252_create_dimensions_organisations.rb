class CreateDimensionsOrganisations < ActiveRecord::Migration[5.1]
  def change
    create_table :dimensions_organisations do |t|
      t.string :title
      t.string :slug
      t.string :description
      t.string :link
      t.string :organisation_id
      t.string :organisation_state
      t.string :content_id

      t.timestamps
    end
  end
end
