class SingleItemController < Api::BaseController
  before_action :validate_params!

  def show
    @from = from
    @to = to
    @base_path = format_base_path_param

    @live_edition = find_live_edition
    @time_series_metrics = find_time_series
    @edition_metrics = find_editions
    @aggregations = find_aggregations
  end

private

  def find_live_edition
    live_edition = Dimensions::Edition.live_by_base_path(@base_path).first
    raise Api::NotFoundError, "#{api_request.base_path} not found" if live_edition.nil?

    live_edition
  end

  def find_time_series
    Finders::FindSeries.new
      .between(from:, to:)
      .by_warehouse_item_id(@live_edition.warehouse_item_id)
      .run
  end

  def find_editions
    Metric.edition_metrics.map(&:name)
  end

  def find_aggregations
    Finders::Aggregations.new
      .between(from:, to:)
      .by_warehouse_item_id(@live_edition.warehouse_item_id)
      .run
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
end
