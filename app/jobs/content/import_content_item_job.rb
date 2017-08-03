module Content
  class ImportContentItemJob < ApplicationJob
    def perform(*args)
      Importers::SingleContentItem.run(*args)
    end
  end
end
