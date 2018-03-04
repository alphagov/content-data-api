class SandboxController < ApplicationController
  def index
    query = Facts::Metric
                .between(from, to)
                .by_base_path(base_path)

    @pageviews = query.sum(:pageviews)
    @feedex_issues = query.sum(:number_of_issues)
    @unique_pageviews = query.average(:unique_pageviews)
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
