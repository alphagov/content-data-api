class ImportQualityMetricsJob < ApplicationJob
  sidekiq_options queue: 'publishing_api'

  def run(*args)
    Importers::QualityMetrics.run(*args)
  end
end
