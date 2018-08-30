class Api::Request
  DATE_REGEX = /\A\d\d\d\d-\d\d-\d\d\Z/

  private_constant :DATE_REGEX

  include ActiveModel::Validations

  attr_reader :metrics, :from, :to, :base_path

  validates :from, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :to, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :base_path, presence: true
  validate :from_before_to, if: :have_a_date_range?
  validate :verify_metrics

  def initialize(params)
    @metrics = params[:metrics]
    @from = params[:from]
    @to = params[:to]
    @base_path = params[:base_path]
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

  def verify_metrics
    metrics.each do |metric|
      errors.add("metric", "is not included in the list") unless Metric.find_all.map(&:name).include?(metric)
    end
  end

end
