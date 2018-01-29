require 'google/apis/analyticsreporting_v4'


module GoogleAnalytics
  module Responses
    class OneAndSixMonthPageviewsResponse
      include Google::Apis::AnalyticsreportingV4

      def parse(response)
        report = response.reports.first
        # If none of the provided base paths have associated pageviews, then
        # GA returns nil instead of an empty array
        Array(report.data.rows).map do |row|
          one_month_values = row.metrics.first.values.map(&:to_i)
          six_months_values = row.metrics.second.values.map(&:to_i)

          {
            base_path: row.dimensions.first,
            one_month_page_views: one_month_values.first,
            one_month_unique_page_views: one_month_values.second,
            six_months_page_views: six_months_values.first,
            six_months_unique_page_views: six_months_values.second,
          }
        end
      end
    end
  end
end
