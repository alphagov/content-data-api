class Queries::Metrics
  def self.run(from:, to:, base_path: nil)
    metrics = new.between(from, to)

    if base_path.present?
      metrics = metrics.where('dimensions_items.base_path like (?)', base_path)
    end

    metrics
  end

  attr_reader :relation

  def initialize(relation = Facts::Metric.all)
    @relation = relation.
      joins(:dimensions_date).
      joins(:dimensions_item)
  end

  def between(from, to)
    relation.where('dimensions_dates.date BETWEEN ? AND ?', from, to)
  end
end
