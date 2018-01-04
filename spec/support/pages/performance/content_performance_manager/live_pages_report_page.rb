require_relative './base_page'

module ContentPerformanceManager
  class LivePagesReportPage < BasePage
    set_url '/content/reports/live-pages'

    section :filter, '[data-test-id=filter-form]' do
      element :organisation, '[data-test-id=organisation-select]'
      element :submit, '[data-test-id=submit-button]'
    end

    element :line_chart, '[data-test-id=line-chart]'

    section :summary_table, '[data-test-id=summary-table]' do
      elements :dates, '[data-test-class=date]'
      elements :live_pages, '[data-test-class=live-pages]'
    end
  end
end
