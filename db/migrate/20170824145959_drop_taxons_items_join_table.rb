class DropTaxonsItemsJoinTable < ActiveRecord::Migration[5.1]
  def change
    drop_join_table :content_items, :taxons do |t|
      t.index [:content_item_id]
      t.index [:taxon_id, :content_item_id], name: "index_content_item_taxonomies", unique: true
    end
  end
end
