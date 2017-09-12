class DropInventoryRules < ActiveRecord::Migration[5.1]
  def change
    drop_table :inventory_rules do |t|
      t.belongs_to :subtheme
      t.string :link_type, null: false
      t.string :target_content_id, null: false
      t.timestamps
    end
  end
end
