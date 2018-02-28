class AddNumberOfIssuesToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :facts_metrics, :number_of_issues, :integer
  end
end
