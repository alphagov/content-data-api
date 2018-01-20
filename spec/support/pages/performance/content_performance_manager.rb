require_relative 'content_performance_manager/home_page'
require_relative 'content_performance_manager/live_pages_report_page'

module ContentPerformanceManager
  def self.home_page
    HomePage.new
  end

  def self.live_pages_report
    LivePagesReportPage.new
  end
end
