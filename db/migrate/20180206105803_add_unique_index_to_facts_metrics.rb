class AddUniqueIndexToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_index :facts_metrics,
              %i(dimensions_date_id dimensions_item_id),
              name: 'index_facts_metrics_unique',
              unique: true
  end
end
