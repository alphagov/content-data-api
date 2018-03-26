# FIXME
class Api::Organisation
  DATE_REGEX = /\A\d\d\d\d-\d\d-\d\d\Z/
  INVALID_DATE_MESSAGE = "Dates should use the format YYYY-MM-DD"
  CONTENT_ID_REGEX = /\A[0-9A-F]{8}-[0-9A-F]{4}-[1-5][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\Z/i

  private_constant :DATE_REGEX
  private_constant :CONTENT_ID_REGEX
  private_constant :INVALID_DATE_MESSAGE

  include ActiveModel::Validations

  attr_reader :metric, :from, :to, :organisation_id

  validates :metric, presence: true, inclusion: { in: Rails.configuration.valid_metric_names }
  validates :from, presence: true, format: { with: DATE_REGEX, message: INVALID_DATE_MESSAGE }
  validates :to, presence: true, format: { with: DATE_REGEX, message: INVALID_DATE_MESSAGE }
  validates :organisation_id, presence: true, format: { with: CONTENT_ID_REGEX, message: "Organisation ID must be a UUID." }
  validate :from_before_to, if: :have_a_date_range?

  def initialize(params)
    @metric = params[:metric]
    @from = params[:from]
    @to = params[:to]
    @organisation_id = params[:organisation_id]
  end

private

  def have_a_date_range?
    from.present? && to.present? && from =~ DATE_REGEX && to =~ DATE_REGEX
  end

  def from_before_to
    # This is a string comparison, but the sort order is the same as for dates.
    if from > to
      errors.add("from,to", "`from` parameter can't be after the `to` parameter")
    end
  end
end