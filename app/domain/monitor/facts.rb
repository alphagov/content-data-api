class Monitor::Facts
 
  def self.run(*args)
    new(*args).run
  end

  def run
    count_facts_metrics!
    count_facts_daily_metrics!
  end

private

  def count_facts_metrics!
    path = path_for('all_metrics')
    count = Facts::Metric.count

    GovukStatsd.count(path, count)
  end

  def count_facts_daily_metrics!
    path = path_for('daily_metrics')
    count = Facts::Metric.for_yesterday.count

    GovukStatsd.count(path, count)
  end


  def path_for(item)
    "monitor.facts.#{item}"
  end
end
