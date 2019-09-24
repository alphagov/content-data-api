class AddIndexToLastThirtyDays < ActiveRecord::Migration[5.2]
  def change
    add_index :aggregations_search_last_thirty_days, %w(dimensions_edition_id upviews), name: "index_on_last_thirty_days_edition_id_upviews"
  end
end
