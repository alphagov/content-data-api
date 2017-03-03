class CreateJoinTableContentItemTaxonomy < ActiveRecord::Migration[5.0]
  def change
    create_join_table :content_items, :taxonomies do |t|
      t.index [:content_item_id]
      t.index [:taxonomy_id, :content_item_id], name: "index_content_item_taxonomies", unique: true
    end
  end
end
