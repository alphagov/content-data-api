class ImportContentDetailsJob < ApplicationJob
  sidekiq_options queue: 'publishing_api'

  def run(*args)
    Importers::ContentDetails.run(*args)
  end
end
