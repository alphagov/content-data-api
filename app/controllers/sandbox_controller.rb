class SandboxController < ApplicationController
  def index
    metrics = Facts::Metric.
      joins(:dimensions_date).
      joins(:dimensions_item).
      where('dimensions_dates.date BETWEEN ? AND ?', from, to)

    @pageviews = metrics.sum("facts_metrics.pageviews")
    @unique_pageviews = metrics.average("facts_metrics.unique_pageviews")
  end

private

  def from
    params[:from] || 1.month.ago.to_date
  end

  def to
    params[:to] || Date.yesterday
  end
end
