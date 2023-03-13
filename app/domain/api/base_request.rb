class Api::BaseRequest
  DATE_REGEX = /\A\d\d\d\d-\d\d-\d\d\Z/

  private_constant :DATE_REGEX

  include ActiveModel::Validations

  attr_reader :from, :to

  validates :from, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :to, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validate :from_before_to, if: :have_a_date_range?

  def initialize(params)
    @from = params[:from]
    @to = params[:to]
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
