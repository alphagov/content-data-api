class Monitor::Aggregations
  include TraceAndRecoverable

  def self.run(*args)
    new(*args).run
  end

  def run
    trap do
      statsd_for_all_monthly_aggregations!
      statsd_for_current_month!
    end
  end

private

  def statsd_for_all_monthly_aggregations!
    path = path_for("all")
    count = ::Aggregations::MonthlyMetric.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_current_month!
    path = path_for("current")
    count = Aggregations::MonthlyMetric
              .where(dimensions_month: Dimensions::Month.current)
              .count

    GovukStatsd.count(path, count)
  end

  def path_for(item)
    "monitor.aggregations.#{item}"
  end
end
