class MetricsController < ApplicationController
  skip_before_action :authenticate_user!

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
end
