require 'google/apis/analyticsreporting_v4'


module GoogleAnalytics
  module Responses
    class PageViewsResponse
      include Google::Apis::AnalyticsreportingV4

      def parse(response)
        report = response.reports.first
        # If none of the provided base paths have associated pageviews, then
        # GA returns nil instead of an empty array
        rows = report.data.rows || []
        rows.map do |row|
          {
            base_path: row.dimensions.first,
            one_month_page_views: row.metrics.first.values.first.to_i,
            six_months_page_views: row.metrics.second.values.first.to_i
          }
        end
      end
    end
  end
end
