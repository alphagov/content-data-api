class RemoveContentItems < ActiveRecord::Migration[5.1]
  def change
    drop_table :content_items do |t|
      t.string :content_id
      t.datetime :public_updated_at
      t.string :base_path
      t.string :title
      t.string :document_type
      t.string :description
      t.integer :one_month_page_views, default: 0
      t.integer :number_of_pdfs, default: 0
      t.integer :six_months_page_views, default: 0
      t.string :publishing_app
      t.string :locale, null: false
      t.integer :number_of_word_files, default: 0
    end
  end
end
