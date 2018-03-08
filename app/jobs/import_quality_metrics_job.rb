class ImportQualityMetricsJob < ApplicationJob
  sidekiq_options queue: 'quality_metrics'

  def run(*args)
    Importers::QualityMetrics.run(*args)
  end
end
