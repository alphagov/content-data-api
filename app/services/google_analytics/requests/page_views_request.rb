require 'google/apis/analyticsreporting_v4'


module GoogleAnalytics
  module Requests
    class PageViewsRequest
      include Google::Apis::AnalyticsreportingV4

      def build(base_paths, start_date: "7daysAgo", end_date: "today")
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
  end
end
