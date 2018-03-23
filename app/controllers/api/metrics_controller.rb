class Api::MetricsController < Api::BaseController
  before_action :validate_params!

  def time_series
    @metrics = query_series
    @metric_params = metric_params
  end

  def summary
    @metrics = query_series
    @metric_params = metric_params
  end

private

  def query_series
    Facts::Metric
      .between(from, to)
      .by_content_id(content_id)
      .by_locale('en')
      .order('dimensions_dates.date asc')
      .group('dimensions_dates.date')
      .sum(metric)
  end

  delegate :from, :to, :metric, :content_id, to: :metric_params

  def metric_params
    @metric_params ||= Api::Metric.new(params.permit(:from, :to, :metric, :content_id, :format))
  end

  def validate_params!
    unless metric_params.valid?
      error_response(
        "validation-error",
        title: "One or more parameters is invalid",
        invalid_params: metric_params.errors.to_hash
      )
    end
  end
end
