class AddMetadataFieldsToDimensionsItem < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :document_type, :string
    add_column :dimensions_items, :content_purpose_supertype, :string
    add_column :dimensions_items, :first_published_at, :datetime
    add_column :dimensions_items, :public_updated_at, :datetime
  end
end
