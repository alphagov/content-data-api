class Monitor::Facts
  def self.run(*args)
    new(*args).run
  end

  def run
    statsd_for_all_metrics!
    statsd_for_yesterday_metrics!

    statsd_for_total_editions!
    statsd_for_yesterday_editions!
  end

private

  def statsd_for_all_metrics!
    path = path_for('all_metrics')
    count = Facts::Metric.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_yesterday_metrics!
    path = path_for('daily_metrics')
    count = Facts::Metric.for_yesterday.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_total_editions!
    path = path_for('all_editions')
    count = Facts::Edition.count

    GovukStatsd.count(path, count)
  end

  def statsd_for_yesterday_editions!
    path = path_for('daily_editions')
    count = Facts::Edition.where(dimensions_date: Dimensions::Date.for(Date.yesterday)).count

    GovukStatsd.count(path, count)
  end

  def path_for(item)
    "monitor.facts.#{item}"
  end
end
