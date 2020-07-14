class Monitor::Etl
  include TraceAndRecoverable
  def self.run(*args)
    new(*args).run
  end

  def run
    trap do
      statsd_for_performance_metrics!
      statsd_for_edition_metrics!
    end
  end

private

  def statsd_for_edition_metrics!
    Metric.edition_metrics.map(&:name).each do |edition_metric|
      path = path_for_edition_metric(edition_metric)

      GovukStatsd.count(path, sum("facts_editions.#{edition_metric}"))
    end
  end

  def statsd_for_performance_metrics!
    Metric.daily_metrics.map(&:name).each do |daily_metric|
      path = path_for_daily_metric(daily_metric)

      GovukStatsd.count(path, sum(daily_metric))
    end
  end

  def sum(selector)
    editions.sum(Arel.sql(selector))
  end

  def path_for_edition_metric(edition_metric)
    "monitor.etl.edition.#{edition_metric}"
  end

  def path_for_daily_metric(daily_metric)
    "monitor.etl.daily.#{daily_metric}"
  end

  def metrics
    @metrics ||= Facts::Metric.for_yesterday
  end

  def editions
    @editions = metrics.joins(dimensions_edition: :facts_edition)
  end
end
