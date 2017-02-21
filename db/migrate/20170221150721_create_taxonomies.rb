class CreateTaxonomies < ActiveRecord::Migration[5.0]
  def change
    create_table :taxonomies do |t|
      t.string :content_id
      t.string :title

      t.timestamps
    end
  end
end
