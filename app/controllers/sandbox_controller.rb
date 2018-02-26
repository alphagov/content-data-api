class SandboxController < ApplicationController
  def index
    @pageviews = Facts::Metric.
      joins(:dimensions_date).
      joins(:dimensions_item).
      sum("facts_metrics.pageviews")
  end
end
