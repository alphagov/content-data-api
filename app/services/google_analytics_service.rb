require 'google/apis/analyticsreporting_v4'
require 'googleauth'

class GoogleAnalyticsService
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

  def page_views(base_paths)
    raise "base_paths isn't an array" unless base_paths.is_a?(Array)

    request_body = build_page_views_body(base_paths)
    data = client.batch_get_reports(request_body).reports[0].data

    data.rows.inject({}) do |page_views, row|
      page_views[row.dimensions[0]] = row.metrics[0].values[0].to_i
      page_views
    end
  end

  def build_page_views_body(base_paths, start_date: "7daysAgo", end_date: "today")
    GetReportsRequest.new.tap do |reports|
      reports.report_requests = Array.new.push(
        ReportRequest.new.tap do |request|
          request.metrics = Array.new.push(
            Metric.new.tap { |metric| metric.expression = "ga:pageViews" }
          )
          request.view_id = ENV["CPM_GOVUK_VIEW_ID"]
          request.dimension_filter_clauses = Array.new.push(
            DimensionFilterClause.new.tap do |dimension_filter_clause|
              dimension_filter_clause.filters = base_paths.map do|base_path|
                DimensionFilter.new.tap do |dimension_filter|
                  dimension_filter.expressions = %W(#{base_path})
                  dimension_filter.dimension_name = "ga:pagePath"
                  dimension_filter.operator = "EXACT"
                end
              end
            end
          )
          request.dimensions = Array.new.push(
            Dimension.new.tap { |dimension| dimension.name = "ga:pagePath" }
          )
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
