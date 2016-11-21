class CreateContentItems < ActiveRecord::Migration[5.0]
  def change
    create_table :content_items do |t|
      t.string :content_id
      t.references :organisation, foreign_key: true

      t.timestamps
    end
  end
end
