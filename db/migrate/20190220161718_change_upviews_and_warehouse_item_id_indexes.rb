class ChangeUpviewsAndWarehouseItemIdIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :aggregations_search_last_twelve_months, name: :search_last_twelve_months_upviews
    remove_index :aggregations_search_last_six_months, name: :search_last_six_months_upviews
    remove_index :aggregations_search_last_three_months, name: :search_last_three_months_upviews
    remove_index :aggregations_search_last_months, name: :search_last_month_upviews
    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_upviews

    fields = %i[upviews warehouse_item_id]
    order = { upviews: "DESC NULLS LAST", warehouse_item_id: :desc }

    add_index :aggregations_search_last_twelve_months, fields, order: order, name: :search_last_twelve_months_upviews
    add_index :aggregations_search_last_six_months, fields, order: order, name: :search_last_six_months_upviews
    add_index :aggregations_search_last_three_months, fields, order: order, name: :search_last_three_months_upviews
    add_index :aggregations_search_last_months, fields, order: order, name: :search_last_month_upviews
    add_index :aggregations_search_last_thirty_days, fields, order: order, name: :search_last_thirty_days_upviews
  end
end
