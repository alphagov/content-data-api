require_relative './base_page'

module ContentPerformanceManager
  class LivePagesReportPage < BasePage
    set_url '/content/reports/live-pages'

    element :line_chart, '[data-test-id=line-chart]'

    section :summary_table, '[data-test-id=summary-table]' do
      elements :dates, '[data-test-class=date]'
      elements :live_pages, '[data-test-class=live-pages]'
    end
  end
end
