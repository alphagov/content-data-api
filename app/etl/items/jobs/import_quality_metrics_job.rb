class Items::Jobs::ImportQualityMetricsJob < Items::Jobs::ApplicationJob
  sidekiq_options queue: 'quality_metrics'

  def run(*args)
    Items::Importers::QualityMetrics.run(*args)
  rescue StandardError => e
    GovukError.notify(e, extra: { args: args, message: e.message })
    raise e
  end
end
