class Reports::Series
  attr_reader :metric_name, :all_metrics, :values_by_date

  def initialize(metric_name, all_metrics)
    @metric_name = metric_name
    @all_metrics = all_metrics
    @values_by_date = set_values
  end

  def set_values
    all_metrics.map do |metric|
      key = metric.dimensions_date_id.to_s
      value = Metric.is_edition_metric?(metric_name) ? metric.facts_edition.send(metric_name) : metric.send(metric_name)
      { key => value }
    end
  end

  def total
    values_by_date.reduce(0) { |memo, value_by_date| memo + value_by_date.values.first }
  end

  def latest
    values_by_date.last.values.first
  end
end
