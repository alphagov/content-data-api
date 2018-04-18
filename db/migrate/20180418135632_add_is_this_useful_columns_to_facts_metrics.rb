class AddIsThisUsefulColumnsToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :facts_metrics, :is_this_useful_yes, :integer
    add_column :facts_metrics, :is_this_useful_no, :integer
  end
end
