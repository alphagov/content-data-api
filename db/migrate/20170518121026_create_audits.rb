class CreateAudits < ActiveRecord::Migration[5.0]
  def change
    create_table :audits do |t|
      t.string :content_id, null: false
      t.string :uid, null: false

      t.timestamps
    end

    add_index :audits, :content_id, unique: true
    add_index :audits, :uid
  end
end
