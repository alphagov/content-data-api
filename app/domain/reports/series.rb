class Reports::Series
  attr_reader :metric_name, :all_metrics, :time_series

  def initialize(metric_name, all_metrics)
    @metric_name = metric_name
    @all_metrics = all_metrics
    @time_series = format_time_series
  end

  def total
    time_series.reduce(0) { |total, time_point| total + time_point[:value] }
  end

private

  def format_time_series
    all_metrics.map do |metric|
      key = metric.dimensions_date_id.to_s
      value = Metric.is_edition_metric?(metric_name) ? metric.facts_edition.send(metric_name) : metric.send(metric_name)
      { date: key, value: value }
    end
  end
end
