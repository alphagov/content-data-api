class Metric
  include ActiveModel::Model
  attr_accessor :description, :name, :source

  def self.all_metrics
    @all_metrics ||= (daily_metrics + edition_metrics).sort_by(&:name)
  end

  def self.metric_names
    self.all_metrics.map(&:name)
  end

  def self.is_edition_metric?(metric_name)
    edition_metrics.map(&:name).include?(metric_name)
  end

  def self.edition_metrics_names
    edition_metrics.map(&:name)
  end

  def self.edition_metrics
    source['edition'].map { |attributes| Metric.new(attributes) }
  end

  def self.daily_metrics
    source['daily'].map { |attributes| Metric.new(attributes) }
  end

  def self.source
    @source ||= YAML.load_file(Rails.root.join('config', 'metrics.yml'))
  end
end
