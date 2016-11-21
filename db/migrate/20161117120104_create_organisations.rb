class CreateOrganisations < ActiveRecord::Migration[5.0]
  def change
    create_table :organisations do |t|
      t.string :content_id
      t.string :slug
      t.integer :number_of_pages, default: 0

      t.timestamps
    end
  end
end
