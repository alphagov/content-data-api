class MetricsController < ApplicationController
  before_action :validate_metric!

  def show
    @metrics = Facts::Metric
      .joins(:dimensions_date)
      .joins(:dimensions_item)
      .where(dimensions_items: { content_id: content_id })
      .where('dimensions_dates.date between ? and ?', from, to)
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
