module Content
  class Jobs::ImportQualityMetricsJob < Content::Jobs::ApplicationJob
    sidekiq_options queue: 'quality_metrics'

    def run(*args)
      Jobs::Importers::QualityMetrics.run(*args)
    end
  end
end
