class Api::MetricsRequest < Api::BaseRequest
  attr_reader :metrics, :base_path

  validates :base_path, presence: true
  validates :metrics, presence: true
  validate :verify_metrics, if: [Proc.new { metrics.present? }]

  def initialize(params)
    super(params)
    @metrics = params[:metrics]
    @base_path = params[:base_path]
  end

private

  def verify_metrics
    if metrics.blank?
      errors.add("metrics", "metrics are required")
      return false
    end

    metrics.each do |metric|
      errors.add("metric", "is not included in the list") unless Metric.find_all_names.include?(metric)
    end
  end
end
