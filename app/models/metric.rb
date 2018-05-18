class Metric
  def self.all_metrics
    @all_metrics ||= (daily_metrics + edition_metrics).sort_by { |metric| metric[:name] }
  end

  def self.valid_metric_names
    self.all_metrics.map { |metric| metric['name'] }
  end

  def self.is_edition_metric?(metric_name)
    edition_metrics.any? { |edition_metric| edition_metric['name'] == metric_name }
  end

  def self.edition_metrics_names
    edition_metrics.map { |metric|  metric['name'] }
  end

  def self.edition_metrics
    source['edition']
  end

  def self.daily_metrics
    source['daily']
  end

  def self.source
    @source ||= YAML.load_file(Rails.root.join('config', 'metrics.yml'))
  end
end
