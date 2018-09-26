class AddConstraintsToSatisfactionScoreColumns < ActiveRecord::Migration[5.2]
  def change
    change_column :facts_metrics, :satisfaction_score, :float, default: 0.0, null: false
    change_column :facts_metrics, :is_this_useful_yes, :integer, default: 0, null: false
    change_column :facts_metrics, :is_this_useful_no, :integer, default: 0, null: false
  end
end
