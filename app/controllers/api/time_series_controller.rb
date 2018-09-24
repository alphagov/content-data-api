class Api::TimeSeriesController < Api::BaseController
  before_action :validate_params!

  def show
    @series = query_series
  end

private

  def query_series
    Reports::FindSeries.new
       .between(from: from, to: to)
       .by_base_path(format_base_path_param)
       .by_metrics(params[:metrics])
       .run
  end

  def format_base_path_param
    #  add '/' as param is received without leading forward slash which is needed to query by base_path.
    "/#{base_path}"
  end

  delegate :from, :to, :base_path, :metrics, to: :api_request

  def api_request
    @api_request ||= Api::MetricsRequest.new(permitted_params)
  end

  def permitted_params
    params.permit(:from, :to, :base_path, :format, metrics: [])
  end

  def validate_params!
    unless api_request.valid?
      error_response(
        "validation-error",
        title: "One or more parameters is invalid",
        invalid_params: api_request.errors.to_hash
      )
    end
  end
end
