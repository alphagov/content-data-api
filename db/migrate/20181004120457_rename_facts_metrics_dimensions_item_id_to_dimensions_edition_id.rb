class RenameFactsMetricsDimensionsItemIdToDimensionsEditionId < ActiveRecord::Migration[5.2]
  def change
    rename_column :facts_metrics, :dimensions_item_id, :dimensions_edition_id

    rename_index :facts_metrics, 'metrics_item_id_date_id', 'metrics_edition_id_date_id'
  end
end
