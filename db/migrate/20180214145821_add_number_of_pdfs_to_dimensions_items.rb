class AddNumberOfPdfsToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :number_of_pdfs, :integer
  end
end
