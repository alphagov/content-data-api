class AddPageviewsToFactsMetrics < ActiveRecord::Migration[5.1]
  def change
    add_column :facts_metrics, :pageviews, :integer
    add_column :facts_metrics, :unique_pageviews, :integer
  end
end
