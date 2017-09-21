module Content
  class ImportItemJob < ApplicationJob
    def run(*args)
      Importers::SingleContentItem.run(*args)
    end
  end
end
