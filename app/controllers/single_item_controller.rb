class SingleItemController < Api::BaseController
  before_action :validate_params!

  def show
    @to = params[:to]
    @from = params[:from]
    @series = query_series
    @metadata = metadata
  end

private

  def query_series
    Reports::FindSeries.new
        .between(from: @from, to: @to)
        .by_base_path(format_base_path_param)
        .by_metrics(%i(unique_pageviews pageviews))
        .run
  end

  def metadata
    latest_item = Dimensions::Item.latest_by_base_path(format_base_path_param).first
    raise Api::NotFoundError.new("#{api_request.base_path} not found") if latest_item.nil?
    latest_item.metadata
  end

  def api_request
    @api_request ||= Api::SinglePageRequest.new(permitted_params)
  end

  def permitted_params
    params.permit(:from, :to, :base_path, :format)
  end

  def base_path
    params[:base_path]
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
