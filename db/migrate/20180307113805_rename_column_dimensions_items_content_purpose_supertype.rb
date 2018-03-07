class RenameColumnDimensionsItemsContentPurposeSupertype < ActiveRecord::Migration[5.1]
  def change
    rename_column :dimensions_items, :content_purpose_supertype, :content_purpose_document_supertype
  end
end
