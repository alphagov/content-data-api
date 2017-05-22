class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.string :source_content_id
      t.string :link_type
      t.string :target_content_id
      t.timestamps
    end
  end
end
