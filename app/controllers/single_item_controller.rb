class SingleItemController < Api::BaseController
  before_action :validate_params!

  def show
    @to = params[:to]
    @from = params[:from]
    @base_path = format_base_path_param
    @metadata = metadata
    @time_series_metrics = query_time_series_metrics
    @edition_metrics = query_edition_metrics
  end

private

  def metadata
    metadata = Queries::FindMetadata.run(@base_path)
    raise Api::NotFoundError.new("#{api_request.base_path} not found") if metadata.nil?
    metadata
  end

  def query_time_series_metrics
    Queries::FindSeries.new
      .between(from: @from, to: @to)
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

  def query_edition_metrics
    Queries::FindEditionMetrics.run(@base_path, %w[words pdf_count])
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
