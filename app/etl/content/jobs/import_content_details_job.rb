module Content
  class Jobs::ImportContentDetailsJob < Content::Jobs::ApplicationJob
    sidekiq_options queue: 'publishing_api'

    def run(*args)
      Jobs::Importers::ContentDetails.run(*args)
    end
  end
end
