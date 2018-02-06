class DropDimensionsOrganisations < ActiveRecord::Migration[5.1]
  def change
    drop_table :dimensions_organisations do |t|
      t.string "title"
      t.string "slug"
      t.string "description"
      t.string "link"
      t.string "organisation_id"
      t.string "state"
      t.string "content_id"
      t.timestamps null: false
    end
  end
end
