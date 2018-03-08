class Api::MetricsController < ApiController
  before_action :validate_params!

  def show
    query = Facts::Metric
              .between(from, to)
              .by_content_id(content_id)

    @metrics = query
                 .order('dimensions_dates.date asc')
                 .group('dimensions_dates.date')
                 .sum(metric)

    @metric_params = metric_params
  end

private

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
