class SandboxController < ApplicationController
  def index
    @pageviews = Facts::Metric.
      joins(:dimensions_date).
      joins(:dimensions_item).
      sum("facts_metrics.pageviews")
    @unique_pageviews = Facts::Metric.
      joins(:dimensions_date).
      joins(:dimensions_item).
      average("facts_metrics.unique_pageviews")
  end
end
