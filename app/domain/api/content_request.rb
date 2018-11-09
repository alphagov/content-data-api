class Api::ContentRequest < Api::BaseRequest
  attr_reader :organisation_id, :document_type, :page, :page_size, :date_range
  validate :valid_organisation_id
  validate :valid_date_range

  validates_numericality_of :page, :page_size, allow_nil: true

  def initialize(params)
    super(params)

    @organisation_id = params[:organisation_id]
    @document_type = params[:document_type]
    @page = params[:page].try(:to_i)
    @page_size = params[:page_size].try(:to_i)
    @date_range = params[:date_range]
  end

  def to_filter
    {
      organisation_id: organisation_id,
      document_type: document_type,
      date_range: date_range,
      page: page,
      page_size: page_size,
      to: to,
      from: from,
    }
  end

private

  def valid_date_range
    return true if DateRange.valid?(date_range) || date_range.blank?

    errors.add('date_range', 'this is not a valid date range')
  end

  def valid_organisation_id
    return true if UUID.validate organisation_id
    errors.add('organisation_id', 'this is not a valid organisation id')
  end
end
