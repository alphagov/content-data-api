class Api::MetricsController < ApplicationController
  before_action :validate_metric!

  def show
    query = Facts::Metric
              .between(from, to)
              .by_content_id(content_id)

    @metrics = query
                 .order('dimensions_dates.date asc')
                 .group('dimensions_dates.date')
                 .sum("facts_metrics.#{metric}")
  end

private

  METRIC_WHITELIST = %w[pageviews unique_pageviews].freeze

  def content_id
    @content_id ||= params[:content_id]
  end

  def from
    @from ||= params[:from]
  end

  def to
    @to ||= params[:to]
  end

  def metric
    @metric ||= params[:metric]
  end

  def validate_metric!
    head :bad_request unless METRIC_WHITELIST.include? metric
  end
end
