class RemoveContentPurposeDocumentSupertypeColumnFromDimensionsEditions < ActiveRecord::Migration[5.2]
  def change
    remove_column :dimensions_editions, :content_purpose_document_supertype, :string
  end
end
