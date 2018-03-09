class Api::Metric
  DATE_REGEX = /\A\d\d\d\d-\d\d-\d\d\Z/
  CONTENT_ID_REGEX = /\A[0-9A-F]{8}-[0-9A-F]{4}-[1-5][0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}\Z/i

  private_constant :DATE_REGEX
  private_constant :CONTENT_ID_REGEX

  include ActiveModel::Validations

  attr_reader :metric, :from, :to, :content_id

  validates :metric, presence: true, inclusion: { in: Rails.configuration.valid_metric_names }
  validates :from, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :to, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :content_id, presence: true, format: { with: CONTENT_ID_REGEX, message: "Content ID must be a UUID." }
  validate :from_before_to, if: :have_a_date_range?

  def initialize(params)
    @metric = params[:metric]
    @from = params[:from]
    @to = params[:to]
    @content_id = params[:content_id]
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
