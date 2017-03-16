class ImportPageviewsJob < ApplicationJob
  queue_as :default
  attr_accessor :google_analytics_service

  def initialize(*)
    super
    self.google_analytics_service = GoogleAnalyticsService.new
  end

  def perform(*args)
    content_items = args[0]
    base_paths = content_items.pluck(:base_path)

    results = google_analytics_service.page_views(base_paths)
    results.each do |result|
      content_item = ContentItem.find_by(base_path: result[:base_path])
      content_item.update!(result.slice(:one_month_page_views, :six_months_page_views))
    end
  end
end
