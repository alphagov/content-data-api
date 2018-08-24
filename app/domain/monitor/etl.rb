class Monitor::ETL
  def run
    count_metrics!
    count_daily_metrics!
    count_edition_metrics!
  end

private

  def count_edition_metrics!
    Metric.edition_metrics.map(&:name).each do |edition_metric|
      GovukStatsd.count("monitor.etl.#{edition_metric}", editions.sum("facts_editions.#{edition_metric}"))
    end
  end

  def count_daily_metrics!
    Metric.daily_metrics.map(&:name).each do |daily_metric|
      GovukStatsd.count("monitor.etl.#{daily_metric}", metrics.sum(daily_metric))
    end
  end

  def count_metrics!
    GovukStatsd.count("monitor.etl.facts_metrics", metrics.count)
  end

  def metrics
    @metrics ||= Facts::Metric.for_yesterday
  end

  def editions
    @editions = metrics.joins(dimensions_item: :facts_edition)
  end
end
