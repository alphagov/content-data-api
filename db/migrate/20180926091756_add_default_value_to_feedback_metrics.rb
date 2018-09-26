class AddDefaultValueToFeedbackMetrics < ActiveRecord::Migration[5.2]
  class MigrationMetric < ActiveRecord::Base
    self.table_name = :facts_metrics
  end
  def up
    say 'Updating nil values in `is_this_useful_yes` column in `facts_metrics`'
    MigrationMetric.where(is_this_useful_yes: nil).update_all(is_this_useful_yes: 0)

    say 'Updating nil values in `is_this_useful_no` column in `facts_metrics`'
    MigrationMetric.where(is_this_useful_no: nil).update_all(is_this_useful_no: 0)

    say 'Updating nil values in `satisfaction_score` column in `facts_metrics`'
    MigrationMetric.update_all(satisfaction_score: 0.0)

    say 'Updating `satisfaction_score` values in `facts_metrics`'
    ActiveRecord::Base.connection.execute(
        <<~SQL
        UPDATE facts_metrics
        SET satisfaction_score = is_this_useful_yes / (is_this_useful_yes + is_this_useful_no::float)
        WHERE (is_this_useful_yes + is_this_useful_no > 0)
    SQL
    )
  end
end
