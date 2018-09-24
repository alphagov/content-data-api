class DropOrganisations < ActiveRecord::Migration[5.1]
  def change
    drop_table :organisations do |t|
      t.string "slug"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "title"
      t.string "content_id"
      t.index %w[slug], name: "index_organisations_on_slug", unique: true
    end
  end
end
