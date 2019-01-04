class AddNotNullConstraintAndIndexToDocumentTypes < ActiveRecord::Migration[5.2]
  def change
    change_column_null :dimensions_editions, :document_type, false
    add_index :dimensions_editions, :document_type
  end
end
