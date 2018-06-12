class AddNotNullConstratintToFactsEditions < ActiveRecord::Migration[5.1]
  def change
    change_column_null :facts_editions, :dimensions_item_id, false
    change_column_null :facts_editions, :dimensions_date_id, false
  end
end
