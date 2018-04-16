class Items::Jobs::ImportContentDetailsJob < Items::Jobs::ApplicationJob
  sidekiq_options queue: 'publishing_api'

  def run(*args)
    Items::Importers::ContentDetails.run(*args)
  end
end
