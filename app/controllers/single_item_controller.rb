class SingleItemController < Api::BaseController
  before_action :validate_params!

  def show
    @from = from
    @to = to
    @base_path = format_base_path_param
    @metadata = find_metadata
    @time_series_metrics = find_time_series
    @edition_metrics = find_editions
    @aggregations = find_aggregations
  end

private

  def find_metadata
    metadata = Queries::FindMetadata.run(@base_path)
    raise Api::NotFoundError.new("#{api_request.base_path} not found") if metadata.nil?
    metadata
  end

  def find_time_series
    Queries::FindSeries.new
      .between(from: from, to: to)
      .by_base_path(@base_path)
      .by_metrics(%i(
        upviews
        pviews
        feedex
        satisfaction
        useful_yes
        useful_no
        searches
      ))
      .run
  end

  def find_editions
    Queries::FindEditionMetrics.run(@base_path, %w[words pdf_count])
  end

  def find_aggregations
    Queries::FindAggregations.new
      .between(from: from, to: to)
      .by_base_path(@base_path)
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
