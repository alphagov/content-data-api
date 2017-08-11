module Content
  class ImportItemJob < ApplicationJob
    def perform(*args)
      Importers::SingleContentItem.run(*args)
    end
  end
end
