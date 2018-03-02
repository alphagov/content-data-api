module Queries::Metrics
  def self.run(from:, to:, base_path: nil)
    metrics = Facts::Metric.
      joins(:dimensions_date).
      joins(:dimensions_item).
      where('dimensions_dates.date BETWEEN ? AND ?', from, to)

    if base_path.present?
      metrics = metrics.where('dimensions_items.base_path like (?)', base_path)
    end

    metrics
  end
end
