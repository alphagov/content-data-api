class AddUniqueIndexesViewAggregationsSearchViews < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_search_last_thirty_days, :warehouse_item_id, unique: true, name: :aggregations_search_last_thirty_days_pk
    add_index :aggregations_search_last_months, :warehouse_item_id, unique: true, name: :aggregations_search_last_months_pk
    add_index :aggregations_search_last_three_months, :warehouse_item_id, unique: true, name: :aggregations_search_last_three_months_pk
    add_index :aggregations_search_last_six_months, :warehouse_item_id, unique: true, name: :aggregations_search_last_six_months_pk
    add_index :aggregations_search_last_twelve_months, :warehouse_item_id, unique: true, name: :aggregations_search_last_twelve_months_pk
  end
end
