module GoogleAnalytics
  class PageViewsResponseFactory
    def self.build(responses)
      Google::Apis::AnalyticsreportingV4::GetReportsResponse.new(
        reports: [
          Google::Apis::AnalyticsreportingV4::Report.new(
            data: Google::Apis::AnalyticsreportingV4::ReportData.new(
              rows:
                responses.map do |response|
                  Google::Apis::AnalyticsreportingV4::ReportRow.new(
                    dimensions: [
                      response.fetch(:base_path)
                    ],
                    metrics: [
                      Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
                        values: [
                          response.fetch(:one_month_page_views)
                        ]
                      ),
                      Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
                        values: [
                          response.fetch(:six_months_page_views)
                        ]
                      )
                    ]
                  )
                end
            )
          )
        ]
      )
    end
  end
end
