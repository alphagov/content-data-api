class AddPdfCountToContentItem < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :number_of_pdfs, :integer, default: 0
  end
end
