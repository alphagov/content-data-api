module Content
  class Importers::AllGoogleAnalyticsMetrics
    attr_accessor :batch_size

    def initialize
      self.batch_size = 500
    end

    def run
      ContentItem.find_in_batches(batch_size: batch_size) do |content_items|
        ImportPageviewsJob.perform_later(content_items)
      end
    end
  end
end
