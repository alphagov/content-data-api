class AddIndexDimensionsEditionsDocumentType < ActiveRecord::Migration[5.2]
  def change
    add_index :dimensions_editions, %i[latest document_type]
  end
end
