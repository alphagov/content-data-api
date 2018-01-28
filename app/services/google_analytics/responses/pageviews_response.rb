require 'google/apis/analyticsreporting_v4'

module GoogleAnalytics
  module Responses
    class PageviewsResponse
      include Google::Apis::AnalyticsreportingV4

      def parse(response)
        report = response.reports.first
        # If none of the provided base paths have associated pageviews, then
        # GA returns nil instead of an empty array
        Array(report.data.rows).map do |row|
          values = row.metrics.first.values.map(&:to_i)

          {
            base_path: row.dimensions.first,
            page_views: values.first,
            unique_page_views: values.second,
          }
        end
      end
    end
  end
end
