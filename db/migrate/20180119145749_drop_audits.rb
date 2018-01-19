class DropAudits < ActiveRecord::Migration[5.1]
  def change
    drop_table :audits do |t|
      t.string "content_id", null: false
      t.string "uid", null: false
      t.boolean "change_title"
      t.boolean "change_description"
      t.boolean "change_body"
      t.boolean "change_attachments"
      t.boolean "outdated"
      t.boolean "redundant"
      t.boolean "reformat"
      t.boolean "similar"
      t.text "similar_urls"
      t.text "notes"
      t.text "redirect_urls"
      t.timestamps null: false
    end
  end
end
