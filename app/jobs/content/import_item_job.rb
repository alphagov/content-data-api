module Content
  class ImportItemJob < ApplicationJob
    sidekiq_options queue: 'publishing_api'

    def run(*args)
      Importers::SingleContentItem.run(*args)
    end
  end
end
