class CleanUpUnusedIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :aggregations_search_last_thirty_days, name: :index_on_last_thirty_days_edition_id_upviews

    remove_index :aggregations_search_last_thirty_days, name: :index_on_search_last_thirty_days_unique

    remove_index :aggregations_search_last_month, name: :index_on_last_month_edition_id_upviews
    remove_index :aggregations_search_last_month, name: :index_on_search_last_monthunique

    remove_index :aggregations_search_last_three_months, name: :index_on_last_three_months_edition_id_upviews
    remove_index :aggregations_search_last_three_months, name: :index_on_search_last_three_months_unique

    remove_index :aggregations_search_last_six_months, name: :index_on_last_six_months_edition_id_upviews
    remove_index :aggregations_search_last_six_months, name: :index_on_search_last_six_months_unique

    remove_index :aggregations_search_last_three_months, name: :index_on_last_twelve_months_edition_id_upviews
    remove_index :aggregations_search_last_three_months, name: :index_on_search_last_twelve_months_unique

    remove_index :dimensions_editions, name: :dimensions_editions_title
    remove_index :dimensions_editions, name: :dimensions_editions_base_path
  end
end

