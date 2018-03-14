class RenameNumberOfIssuesToFeedexComments < ActiveRecord::Migration[5.1]
  def change
    rename_column :facts_metrics, :number_of_issues, :feedex_comments
    rename_column :events_feedexes, :number_of_issues, :feedex_comments
  end
end
