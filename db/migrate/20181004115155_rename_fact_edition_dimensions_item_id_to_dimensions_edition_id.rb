class RenameFactEditionDimensionsItemIdToDimensionsEditionId < ActiveRecord::Migration[5.2]
  def change
    rename_column :facts_editions, :dimensions_item_id, :dimensions_edition_id

    rename_index :facts_editions, 'editions_item_id_date_id', 'facts_editions_edition_id_date_id'
  end
end
