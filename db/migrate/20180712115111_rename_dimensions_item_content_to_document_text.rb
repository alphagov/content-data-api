class RenameDimensionsItemContentToDocumentText < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items, :content, :document_text
  end
end
