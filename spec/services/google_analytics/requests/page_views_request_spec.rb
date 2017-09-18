module GoogleAnalytics
  module Requests
    RSpec.describe PageViewsRequest do
      before do
        @google_analytics_govuk_view_id = ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"]
        ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"] = "12345678"
      end

      after do
        ENV["GOOGLE_ANALYTICS_GOVUK_VIEW_ID"] = @google_analytics_govuk_view_id
      end

      context "Get number of page views from the Google Analytics Reporting API" do
        let(:page_views_request) do
          {
            report_requests: [
              {
                metrics: [
                  {
                    expression: "ga:uniquePageviews"
                  }
                ],
                view_id: "12345678",
                dimension_filter_clauses: [
                  {
                    filters: [
                      {
                        expressions: ["/check-uk-visa"],
                        dimension_name: "ga:pagePath",
                        operator: "EXACT"
                      }
                    ]
                  }
                ],
                dimensions: [
                  {
                    name: "ga:pagePath"
                  }
                ],
                date_ranges: [
                  {
                    start_date: "7daysAgo",
                    end_date: "today"
                  }
                ]
              }
            ]
          }.deep_stringify_keys!
        end

        it "builds the requests body with supplied arguments" do
          date_range = page_views_request["report_requests"][0]["date_ranges"][0]
          date_range["start_date"] = "2016/11/22"
          date_range["end_date"] = "2016/12/22"

          request = PageViewsRequest.new.build(
            base_paths: ["/check-uk-visa"],
            start_dates: ["2016/11/22"],
            end_date: "2016/12/22"
            )

          expect(request.as_json).to include(page_views_request)
        end
      end

      context "When there are blank base paths" do
        it "does not include them in the request" do
          request = PageViewsRequest.new.build(
            base_paths: ["/foo", "", nil, "/bar"],
            start_dates: ["2017/09/18"],
          )

          filters = request.to_h[:report_requests][0][:dimension_filter_clauses][0][:filters]
          base_paths = filters.map { |filter| filter[:expressions][0] }

          expect(base_paths).to contain_exactly("/foo", "/bar")
        end
      end
    end
  end
end
