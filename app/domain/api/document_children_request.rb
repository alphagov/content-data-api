class Api::DocumentChildrenRequest
  VAILD_SORT_KEYS = (Metric.daily_metrics.map(&:name) + %w[title document_type sibling_order]).freeze
  VALID_SORT_DIRECTIONS = %w[asc desc].freeze
  VALID_TIME_PERIODS = SpecificMonths::VALID_SPECIFIC_MONTHS + ["past-30-days", "last-month", "past-3-months", "past-6-months", "past-year"].freeze
  include ActiveModel::Validations
  include SpecificMonths

  validate :valid_time_period
  validate :valid_sort_key
  validate :valid_sort_direction

  def initialize(params)
    @time_period = params[:time_period]
    @sort_key, @sort_direction = parse_sort_parameter(params[:sort])
  end

  def to_filter
    {
      time_period: @time_period,
      sort_key: @sort_key,
      sort_direction: @sort_direction,
    }
  end

private

  def parse_sort_parameter(sort_param)
    sort_param.present? ? sort_param.split(":", 2) : [nil, nil]
  end

  def valid_sort_key
    return true if @sort_key.in?(VAILD_SORT_KEYS) || @sort_key.nil?

    errors.add("sort", "this is not a valid sort key")
  end

  def valid_sort_direction
    return true if @sort_direction.in?(VALID_SORT_DIRECTIONS) || @sort_direction.nil?

    errors.add("sort", "this is not a valid sort direction")
  end

  def valid_time_period
    return true if @time_period.in?(VALID_TIME_PERIODS) || @time_period.blank?

    errors.add("time_period", "this is not a valid time period")
  end
end
