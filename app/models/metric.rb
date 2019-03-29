class Metric
  include ActiveModel::Model
  include Comparable
  attr_accessor :description, :name, :source

  def self.find_all
    @find_all ||= (daily_metrics + edition_metrics).sort
  end

  def self.find_all_names
    find_all.map(&:name)
  end

  def self.is_edition_metric?(metric_name)
    edition_metrics.map(&:name).include?(metric_name)
  end

  def self.edition_metrics
    source['edition'].map { |attributes| Metric.new(attributes) }
  end

  def self.daily_metrics
    source['daily'].map { |attributes| Metric.new(attributes) }
  end

  def self.ga_metrics
    ga_source = source['daily'].select { |value| value['source'] == 'Google Analytics' }
    ga_source.map { |attributes| Metric.new(attributes) }
  end

  def self.source
    @source ||= YAML.load_file(Rails.root.join('config', 'metrics.yml'))
  end

  def <=>(other)
    name <=> other.name
  end
end
