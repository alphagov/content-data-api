class RemoveLinks < ActiveRecord::Migration[5.1]
  def change
    drop_table :links do |t|
      t.string :source_content_id
      t.string :link_type
      t.string :target_content_id
    end
  end
end
