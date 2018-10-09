class Api::TimeSeriesController < Api::BaseController
  before_action :validate_params!

  def show
    @series = query_series
  end

private

  def query_series
    Queries::FindSeries.new
       .between(from: from, to: to)
       .by_base_path(format_base_path_param)
       .by_metrics(params[:metrics])
       .run
  end

  delegate :from, :to, :base_path, :metrics, to: :api_request

  def api_request
    @api_request ||= Api::MetricsRequest.new(permitted_params)
  end

  def permitted_params
    params.permit(:from, :to, :base_path, :format, metrics: [])
  end
end
