class MetricBuilder
  def run_all(content_item_attributes)
    run(content_item_metrics, content_item_attributes)
  end

  def run_collection(content_items)
    run(collection_metrics, content_items)
  end

private

  def run(metrics_to_run, data)
    metrics = metrics_to_run.map do |metric_klass|
      metric_klass.new(data).run
    end
    metrics.reduce(:merge)
  end

  def content_item_metrics
    [
      Metrics::NumberOfPdfs
    ]
  end

  def collection_metrics
    [
      Metrics::TotalPages
    ]
  end
end
