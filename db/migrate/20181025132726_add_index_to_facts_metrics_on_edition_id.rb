class AddIndexToFactsMetricsOnEditionId < ActiveRecord::Migration[5.2]
  def change
    add_index :facts_metrics, :dimensions_edition_id
  end
end
