class Api::MetricsController < ApplicationController
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

  rescue_from(ActionController::UnpermittedParameters) do |pme|
    error_response(
      "unknown-parameter",
      title: "One or more parameter names are invalid",
      invalid_params: pme.params
    )
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

  def error_response(type, error_hash)
    error_hash.merge!(type: "https://content-performance-api.publishing.service.gov.uk/errors/##{type}")
    render json: error_hash, status: :bad_request, content_type: "application/problem+json"
  end
end
