class AddIndexForContentList < ActiveRecord::Migration[5.2]
  def change
    # This index is required for the query we run to get the data
    # for the /content endpoint. We GROUP_BY these columns.
    add_index :dimensions_items, %i[content_uuid base_path title document_type], name: 'index_for_content_query'
  end
end
