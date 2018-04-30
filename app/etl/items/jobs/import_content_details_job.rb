class Items::Jobs::ImportContentDetailsJob < Items::Jobs::ApplicationJob
  sidekiq_options queue: 'publishing_api'

  def run(*args, **options)
    Items::Importers::ContentDetails.run(*args, **options)
  end
end
