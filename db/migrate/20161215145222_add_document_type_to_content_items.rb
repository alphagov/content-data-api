class AddDocumentTypeToContentItems < ActiveRecord::Migration[5.0]
  def change
    add_column :content_items, :document_type, :string
  end
end
