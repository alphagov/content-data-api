class Queries::FindEditionMetrics
  def self.run(base_path, metrics_names)
    item = Dimensions::Edition.find_by(base_path: base_path, latest: true)
    edition = item.facts_edition
    metrics_names.map do |metric_name|
      { name: metric_name, value: edition.attributes[metric_name] }
    end
  end
end
