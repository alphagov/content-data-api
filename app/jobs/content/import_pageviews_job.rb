module Content
  class ImportPageviewsJob < ApplicationJob
    def run(*args)
      base_paths = args[0]
      Importers::Pageviews.run(base_paths)
    end
  end
end
