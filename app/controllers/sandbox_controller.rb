class SandboxController < ApplicationController
  def index
    metrics = Queries::Metrics.run(from: from, to: to, base_path: base_path)

    @pageviews = metrics.sum("facts_metrics.pageviews")
    @unique_pageviews = metrics.average("facts_metrics.unique_pageviews")
  end

private

  def from
    params[:from] ||= 5.days.ago.to_date
  end

  def to
    params[:to] ||= Date.yesterday
  end

  def base_path
    params[:base_path]
  end
end
