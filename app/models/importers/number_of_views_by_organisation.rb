module Importers
  class NumberOfViewsByOrganisation
    BATCH_SIZE = 3000

    def run(slug)
      organisation = Organisation.find_by(slug: slug)
      google_analytics_service = GoogleAnalyticsService.new

      organisation.content_items.find_in_batches(batch_size: BATCH_SIZE) do |content_items|
        base_paths = content_items.pluck(:base_path)

        results = google_analytics_service.page_views(base_paths)
        results.each do |result|
          content_item = ContentItem.find_by(base_path: result[:base_path])
          content_item.update!(one_month_page_views: result[:page_views][:one_month])
        end
      end
    end
  end
end
