class Importers::AllGoogleAnalyticsMetrics
  attr_accessor :batch_size

  def initialize
    self.batch_size = 500
  end

  def run
    Item.find_in_batches(batch_size: batch_size) do |content_items|
      base_paths = content_items
        .map(&:base_path)
        .select(&:present?)
      ImportPageviewsJob.perform_async(base_paths)
    end
  end
end
