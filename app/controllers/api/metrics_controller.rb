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

private

  delegate :from, :to, :metric, :content_id, to: :metric_params

  def metric_params
    @metric_params ||= Api::Metric.new(params)
  end

  def validate_params!
    unless metric_params.valid?
      response = {
        type: "https://content-performance-api.publishing.service.gov.uk/errors/#validation-error",
        title: "One or more parameters is invalid",
        invalid_params: metric_params.errors.to_hash
      }
      render json: response, status: :bad_request, content_type: "application/problem+json"
    end
  end
end
