class Api::ContentRequest
  VAILD_SORT_ATTRIBUTES = (Metric.daily_metrics.map(&:name) + %w[title document_type]).freeze
  VALID_SORT_DIRECTIONS = %w[asc desc].freeze
  VALID_TIME_PERIODS = SpecificMonths::VALID_SPECIFIC_MONTHS + ["past-30-days", "last-month", "past-3-months", "past-6-months", "past-year"].freeze
  include ActiveModel::Validations
  include SpecificMonths

  attr_reader :organisation_id, :document_type, :page, :page_size, :date_range, :search_term

  validate :valid_organisation_id
  validate :valid_date_range
  validate :valid_sort_attribute
  validate :valid_sort_direction

  validates_numericality_of :page, :page_size, allow_nil: true

  def initialize(params)
    @organisation_id = params[:organisation_id]
    @document_type = params[:document_type]
    @page = params[:page].try(:to_i)
    @search_term = params[:search_term]
    @page_size = params[:page_size].try(:to_i)
    @date_range = params[:date_range]
    @sort_attribute, @sort_direction = parse_sort_parameter(params[:sort])
  end

  def to_filter
    {
      organisation_id: organisation_id,
      document_type: document_type,
      date_range: date_range,
      search_term: search_term,
      page: page,
      page_size: page_size,
      sort_attribute: @sort_attribute,
      sort_direction: @sort_direction,
    }
  end

private

  def parse_sort_parameter(sort_param)
    sort_param.present? ? sort_param.split(":", 2) : [nil, nil]
  end

  def valid_sort_attribute
    return true if @sort_attribute.in?(VAILD_SORT_ATTRIBUTES) || @sort_attribute.nil?

    errors.add("sort", "this is not a valid sort attribute")
  end

  def valid_sort_direction
    return true if @sort_direction.in?(VALID_SORT_DIRECTIONS) || @sort_direction.nil?

    errors.add("sort", "this is not a valid sort direction")
  end

  def valid_date_range
    return true if date_range.in?(VALID_TIME_PERIODS) || date_range.blank?

    errors.add("date_range", "this is not a valid date range")
  end

  def valid_organisation_id
    return true if %w[all none].include? organisation_id
    return true if UUID.validate organisation_id

    errors.add("organisation_id", "this is not a valid organisation id")
  end
end
