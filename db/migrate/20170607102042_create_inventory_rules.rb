class CreateInventoryRules < ActiveRecord::Migration[5.1]
  def change
    create_table :inventory_rules do |t|
      t.belongs_to :subtheme
      t.string :link_type, null: false
      t.string :target_content_id, null: false
      t.timestamps
    end

    add_index :inventory_rules,
              %i(subtheme_id link_type target_content_id),
              unique: true,
              name: "index_subtheme_link_type_content_id"
  end
end
