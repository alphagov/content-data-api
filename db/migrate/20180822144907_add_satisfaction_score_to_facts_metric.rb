class AddSatisfactionScoreToFactsMetric < ActiveRecord::Migration[5.2]
  def change
    add_column :facts_metrics, :satisfaction_score, :float
  end
end
