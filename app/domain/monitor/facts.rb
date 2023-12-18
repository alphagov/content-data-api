class Monitor::Facts
  include TraceAndRecoverable

  def self.run(*args)
    new(*args).run
  end

  def run
    trap do
      statsd_for_all_metrics!
      statsd_for_two_days_ago_metrics!
      statsd_for_total_editions!
      statsd_for_two_days_ago_editions!
    end
  end

private

  def statsd_for_all_metrics!
    path = path_for("all_metrics")
    count = Facts::Metric.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_two_days_ago_metrics!
    path = path_for("daily_metrics")
    count = Facts::Metric.for_two_days_ago.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_total_editions!
    path = path_for("all_editions")
    count = Facts::Edition.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_two_days_ago_editions!
    path = path_for("daily_editions")
    count = Facts::Edition.where(dimensions_date: Dimensions::Date.find_existing_or_create(Time.zone.today - 2)).count

    GovukStatsd.count(path, count)
  end

  def path_for(item)
    "monitor.facts.#{item}"
  end
end
