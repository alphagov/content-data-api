class ImportOneAndSixMonthPageviewsJob < ApplicationJob
  sidekiq_options queue: 'google_analytics'

  def run(*args)
    base_paths = args[0]
    Importers::OneAndSixMonthPageviews.run(base_paths)
  end
end
