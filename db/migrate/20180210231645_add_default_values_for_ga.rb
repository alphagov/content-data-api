class AddDefaultValuesForGa < ActiveRecord::Migration[5.1]
  class Facts::Metric < ApplicationRecord
  end

  def up
    Facts::Metric.update_all(pageviews: 0, unique_pageviews: 0)

    change_column :facts_metrics, :pageviews, :integer, default: 0
    change_column :facts_metrics, :unique_pageviews, :integer, default: 0
  end

  def down; end
end
