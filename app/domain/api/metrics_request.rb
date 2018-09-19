class Api::MetricsRequest
  DATE_REGEX = /\A\d\d\d\d-\d\d-\d\d\Z/

  private_constant :DATE_REGEX

  include ActiveModel::Validations

  attr_reader :metrics, :from, :to, :base_path

  validates :from, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :to, presence: true, format: { with: DATE_REGEX, message: "Dates should use the format YYYY-MM-DD" }
  validates :base_path, presence: true, if: :requires_base_path
  validate :from_before_to, if: :have_a_date_range?
  validates :metrics, presence: true, if: :requires_metrics
  validate :verify_metrics, if: [Proc.new { metrics.present? }, :requires_metrics]

  def initialize(params, requires_metrics: true, requires_base_path: true)
    @metrics = params[:metrics]
    @from = params[:from]
    @to = params[:to]
    @base_path = params[:base_path]
    @requires_metrics = requires_metrics
    @requires_base_path = requires_base_path
  end

private

  attr_reader :requires_metrics, :requires_base_path

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
    if metrics.blank?
      errors.add("metrics", "metrics are required")
      return false
    end

    metrics.each do |metric|
      errors.add("metric", "is not included in the list") unless Metric.find_all.map(&:name).include?(metric)
    end
  end
end
