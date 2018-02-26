class SandboxController < ApplicationController
  def index
    metrics = Facts::Metric.
      joins(:dimensions_date).
      joins(:dimensions_item).
      where('dimensions_dates.date in (?)', from..to)

    @pageviews = metrics.sum("facts_metrics.pageviews")
    @unique_pageviews = metrics.average("facts_metrics.unique_pageviews")
  end

private

  def from
    @from ||= params[:from]
  end

  def to
    @to ||= params[:to]
  end
end
