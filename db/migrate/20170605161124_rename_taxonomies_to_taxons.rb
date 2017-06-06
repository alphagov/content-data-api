class RenameTaxonomiesToTaxons < ActiveRecord::Migration[5.1]
  def change
    rename_table :taxonomies, :taxons
    rename_table :content_items_taxonomies, :content_items_taxons
    rename_column :content_items_taxons, :taxonomy_id, :taxon_id
  end
end
