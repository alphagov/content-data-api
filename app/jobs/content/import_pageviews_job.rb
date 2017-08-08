module Content
  class ImportPageviewsJob < ApplicationJob
    def perform(*args)
      content_items = args[0]
      Importers::Pageviews.run(content_items)
    end
  end
end
