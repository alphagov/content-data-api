class AddIndexViewsUsingWarehouseItemId < ActiveRecord::Migration[5.2]
  def change
    remove_index :aggregations_search_last_twelve_months, name: :search_last_twelve_months_gin_base_path_upviews
    remove_index :aggregations_search_last_twelve_months, name: :search_last_twelve_months_gin_base_path_organisation_id
    remove_index :aggregations_search_last_twelve_months, name: :search_last_twelve_months_gin_base_path_document_type
    remove_index :aggregations_search_last_six_months, name: :search_last_six_months_gin_base_path_upviews
    remove_index :aggregations_search_last_six_months, name: :search_last_six_months_gin_base_path_organisation_id
    remove_index :aggregations_search_last_six_months, name: :search_last_six_months_gin_base_path_document_type
    remove_index :aggregations_search_last_three_months, name: :search_last_three_months_gin_base_path_upviews
    remove_index :aggregations_search_last_three_months, name: :search_last_three_months_gin_base_path_organisation_id
    remove_index :aggregations_search_last_three_months, name: :search_last_three_months_gin_base_path_document_type
    remove_index :aggregations_search_last_months, name: :search_last_month_gin_base_path_upviews
    remove_index :aggregations_search_last_months, name: :search_last_month_gin_base_path_organisation_id
    remove_index :aggregations_search_last_months, name: :search_last_month_gin_base_path_document_type
    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_gin_base_path_upviews
    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_gin_base_path_organisation_id
    remove_index :aggregations_search_last_thirty_days, name: :search_last_thirty_days_gin_base_path_document_type


    add_index :aggregations_search_last_twelve_months, %i[upviews warehouse_item_id], name: :search_last_twelve_months_upviews
    add_index :aggregations_search_last_twelve_months, %i[organisation_id upviews warehouse_item_id], name: :search_last_twelve_months_organisation_id
    add_index :aggregations_search_last_twelve_months, %i[document_type upviews warehouse_item_id], name: :search_last_twelve_months_document_type
    add_index :aggregations_search_last_six_months, %i[upviews warehouse_item_id], name: :search_last_six_months_upviews
    add_index :aggregations_search_last_six_months, %i[organisation_id upviews warehouse_item_id], name: :search_last_six_months_organisation_id
    add_index :aggregations_search_last_six_months, %i[document_type upviews warehouse_item_id], name: :search_last_six_months_document_type
    add_index :aggregations_search_last_three_months, %i[upviews warehouse_item_id], name: :search_last_three_months_upviews
    add_index :aggregations_search_last_three_months, %i[organisation_id upviews warehouse_item_id], name: :search_last_three_months_organisation_id
    add_index :aggregations_search_last_three_months, %i[document_type upviews warehouse_item_id], name: :search_last_three_months_document_type
    add_index :aggregations_search_last_months, %i[upviews warehouse_item_id], name: :search_last_month_upviews
    add_index :aggregations_search_last_months, %i[organisation_id upviews warehouse_item_id], name: :search_last_month_organisation_id
    add_index :aggregations_search_last_months, %i[document_type upviews warehouse_item_id], name: :search_last_month_document_type
    add_index :aggregations_search_last_thirty_days, %i[upviews warehouse_item_id], name: :search_last_thirty_days_upviews
    add_index :aggregations_search_last_thirty_days, %i[organisation_id upviews warehouse_item_id], name: :search_last_thirty_days_organisation_id
    add_index :aggregations_search_last_thirty_days, %i[document_type upviews warehouse_item_id], name: :search_last_thirty_days_document_type
  end
end
