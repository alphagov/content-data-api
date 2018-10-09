class Api::AggregationsController < Api::BaseController
  before_action :validate_params!, except: :index

  def show
    @series = query_series
    @metadata = metadata
  end

private

  def query_series
    Queries::FindSeries.new
       .between(from: from, to: to)
       .by_base_path(format_base_path_param)
       .by_metrics(params[:metrics])
       .run
  end

  def metadata
    latest_edition = Dimensions::Edition.latest_by_base_path(format_base_path_param).first
    raise Api::NotFoundError.new("#{api_request.base_path} not found") if latest_edition.nil?
    latest_edition.metadata
  end

  delegate :from, :to, :base_path, :metrics, to: :api_request

  def api_request
    @api_request ||= Api::MetricsRequest.new(permitted_params)
  end

  def permitted_params
    params.permit(:from, :to, :base_path, :format, metrics: [])
  end
end
