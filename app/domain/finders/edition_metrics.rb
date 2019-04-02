class Finders::EditionMetrics
  def self.run(base_path, metric_names = nil)
    metric_names ||= Metric.edition_metrics.map(&:name)

    item = Dimensions::Edition.find_by(base_path: base_path, live: true)
    edition = item.facts_edition
    metric_names.map do |metric_name|
      { name: metric_name, value: edition.attributes[metric_name] }
    end
  end
end
