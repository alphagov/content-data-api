require 'google/apis/analyticsreporting_v4'
require 'googleauth'

module Services
  class GoogleAnalytics
    include Google::Apis::AnalyticsreportingV4
    include Google::Auth

    def client(scope: "https://www.googleapis.com/auth/analytics.readonly")
      @client ||= AnalyticsReportingService.new
      @client.authorization ||= ServiceAccountCredentials.make_creds(
        json_key_io: File.open(ENV["GOOGLE_AUTH_CREDENTIALS"]),
        scope: scope
      )
      @client
    end

    def build_page_views_body(base_path, start_date: "7daysAgo", end_date: "today")
      GetReportsRequest.new.tap do |reports|
        reports.report_requests = Array.new.push(
          ReportRequest.new.tap do |request|
            request.metrics = Array.new.push(
              Metric.new.tap { |metric| metric.expression = "ga:pageViews" }
            )
            request.view_id = ENV["CPM_GOVUK_VIEW_ID"]
            request.filters_expression = "ga:pagePath==#{base_path}"
            request.date_ranges = Array.new.push(
              DateRange.new.tap do |date_range|
                date_range.start_date = start_date
                date_range.end_date = end_date
              end
            )
          end
        )
      end
    end
  end
end
