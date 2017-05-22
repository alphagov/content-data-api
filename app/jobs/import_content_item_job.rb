class ImportContentItemJob < ApplicationJob
  def perform(*args)
    content_id = args[0]
    Importers::SingleContentItem.run(content_id)
  end
end
