class AddContentPurposeSubgroupToDimensionsItems < ActiveRecord::Migration[5.1]
  def change
    add_column :dimensions_items, :content_purpose_subgroup, :string
  end
end
