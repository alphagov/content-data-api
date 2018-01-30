require 'google/apis/analyticsreporting_v4'


module GoogleAnalytics
  module Requests
    class PageViewsRequest
      include Google::Apis::AnalyticsreportingV4

      def build(args = {})
        end_date = args[:end_date] || "today"
        GetReportsRequest.new.tap do |reports|
          reports.report_requests = Array.new.push(
            ReportRequest.new.tap do |request|
              request.metrics = (metrics(pageviews) + metrics(unique_page_views))
              request.view_id = view_id
              request.dimension_filter_clauses = filters(args[:base_paths], page_path)
              request.dimensions = dimensions(page_path)
              request.date_ranges = date_ranges(args[:start_dates], end_date)
            end
          )
        end
      end

    private

      def date_ranges(start_dates, end_date)
        date_ranges = start_dates.map do |start_date|
          date_range = DateRange.new
          date_range.start_date = start_date
          date_range.end_date = end_date
          date_range
        end
        date_ranges
      end

      def dimensions(name)
        dimension = Dimension.new
        dimension.name = name
        [dimension]
      end

      def filters(base_paths, name, operator = "EXACT")
        dimension_filter_clause = DimensionFilterClause.new

        dimension_filter_clause.filters = base_paths
          .map { |base_path| filter(base_path, name, operator) }

        [dimension_filter_clause]
      end

      def filter(path, name, operator = "EXACT")
        DimensionFilter.new.tap do |dimension_filter|
          dimension_filter.expressions = [path]
          dimension_filter.dimension_name = name
          dimension_filter.operator = operator
        end
      end

      def metrics(name)
        metric = Metric.new
        metric.expression = name
        [metric]
      end

      def page_path
        "ga:pagePath"
      end

      def pageviews
        "ga:pageviews"
      end

      def unique_page_views
        "ga:uniquePageviews"
      end

      def view_id
        @view_id ||= ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"]
      end
    end
  end
end
