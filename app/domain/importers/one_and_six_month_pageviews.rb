class Importers::OneAndSixMonthPageviews
  def self.run(*args)
    new.run(*args)
  end

  def initialize
    @google_analytics_service = GoogleAnalyticsService.new
  end

  def run(base_paths)
    results = @google_analytics_service.one_and_six_month_pageviews(base_paths)
    results.each do |result|
      content_item = Item.find_by(base_path: result[:base_path])
      content_item.update!(result.slice(:one_month_page_views, :six_months_page_views))
    end
  end
end
