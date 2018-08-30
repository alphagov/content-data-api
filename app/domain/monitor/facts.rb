class Monitor::Facts
 
  def self.run(*args)
    new(*args).run
  end

  def run
    count_facts_metrics!
  end

private

  def count_facts_metrics!
    path = path_for('all_metrics')
    count = Facts::Metric.count

    GovukStatsd.count(path, count)
  end


  def path_for(item)
    "monitor.facts.#{item}"
  end
end
