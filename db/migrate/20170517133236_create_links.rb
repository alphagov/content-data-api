class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.string :source_content_id
      t.string :link_type
      t.string :target_content_id
      t.timestamps
    end

    add_index :links, :source_content_id
    add_index :links, :target_content_id
    add_index :links, :link_type
  end
end
