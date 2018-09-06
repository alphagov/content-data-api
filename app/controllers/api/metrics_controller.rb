class Api::MetricsController < Api::BaseController
  before_action :validate_params!, except: :index

  def time_series
    @series = query_series
    @api_request = api_request
  end

  def summary
    @series = query_series
    @api_request = api_request
    @metadata = metadata
  end

  def index
    items = Metric.find_all
    render json: items
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

  def metadata
    Dimensions::Item.latest_by_base_path(format_base_path_param).first.metadata
  end

  delegate :from, :to, :base_path, :metrics, to: :api_request

  def api_request
    @api_request ||= Api::Request.new(params.permit(:from, :to, :metric, :base_path, :format, metrics: []))
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
