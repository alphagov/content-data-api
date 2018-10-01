class RenameFactsMetricsColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :facts_metrics, :pageviews, :pviews
    rename_column :facts_metrics, :unique_pageviews, :upviews
    rename_column :facts_metrics, :is_this_useful_yes, :useful_yes
    rename_column :facts_metrics, :is_this_useful_no, :useful_no
    rename_column :facts_metrics, :number_of_internal_searches, :searches
    rename_column :facts_metrics, :feedex_comments, :feedex
    rename_column :facts_metrics, :avg_time_on_page, :avg_page_time
    rename_column :facts_metrics, :time_on_page, :page_time
    rename_column :facts_metrics, :satisfaction_score, :satisfaction
  end
end
