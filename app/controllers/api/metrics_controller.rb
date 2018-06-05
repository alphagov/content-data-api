class Api::MetricsController < Api::BaseController
  before_action :validate_params!, except: :index

  def time_series
    @series = query_series
    @api_request = api_request
  end

  def summary
    @series = query_series
    @api_request = api_request
  end

  def index
    items = Metric.find_all
    render json: items
  end

private

  def query_series
    series = Reports::Series.new
               .for_en
               .between(from: from, to: to)
               .by_base_path(format_base_path_param)
               .run
    if Metric.is_edition_metric?(metric)
      series
        .with_edition_metrics
        .order('dimensions_dates.date asc')
        .pluck(:date, "facts_editions.#{metric}").to_h
    else
      series
        .order('dimensions_dates.date asc')
        .pluck(:date, metric).to_h
    end
  end

  def format_base_path_param
    #  add '/' as param is received without leading forward slash which is needed to query by base_path.
    "/#{base_path}"
  end

  delegate :from, :to, :metric, :base_path, to: :api_request

  def api_request
    @api_request ||= Api::Request.new(params.permit(:from, :to, :metric, :base_path, :format))
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
