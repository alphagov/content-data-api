class Items::Jobs::ImportQualityMetricsJob < Items::Jobs::ApplicationJob
  sidekiq_options queue: 'quality_metrics'

  def run(*args)
    Items::Importers::QualityMetrics.run(*args)
  end
end
