class AddUniqueIndexToFactsEditions < ActiveRecord::Migration[5.1]
  def change
    remove_index :facts_editions, :dimensions_item_id
    remove_index :facts_editions, :dimensions_date_id
    add_index :facts_editions, %i[dimensions_item_id dimensions_date_id], name: :editions_item_id_date_id, unique: true
  end
end
