class AddInternalSearchToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :facts_metrics, :number_of_internal_searches, :integer, default: 0
  end
end
