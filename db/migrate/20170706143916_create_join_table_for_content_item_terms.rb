class CreateJoinTableForContentItemTerms < ActiveRecord::Migration[5.1]
  def change
    create_join_table :terms, :content_items do |t|
      t.index [:content_item_id]
      t.index [:term_id]
      t.index [:term_id, :content_item_id], name: "index_terms_content_items", unique: true
    end
  end
end
