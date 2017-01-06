require 'google/apis/analyticsreporting_v4'


module GoogleAnalytics
  module Responses
    class PageViewsResponse
      include Google::Apis::AnalyticsreportingV4

      def parse(response)
        report = response.reports.first
        report.data.rows.map do |row|
          {
            base_path: row.dimensions.first,
            page_views: row.metrics.first.values.first.to_i
          }
        end
      end
    end
  end
end
