class RemoveDimensionsOrganisationIdFromFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    remove_column :facts_metrics, :dimensions_organisation_id, :bigint
  end
end
