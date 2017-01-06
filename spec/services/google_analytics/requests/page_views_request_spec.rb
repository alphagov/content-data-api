require 'rails_helper'

module GoogleAnalytics
  module Requests
    RSpec.describe PageViewsRequest do
      before do
        @cpm_govuk_view_id = ENV["CPM_GOVUK_VIEW_ID"]
        ENV["CPM_GOVUK_VIEW_ID"] = "12345678"
      end

      after do
        ENV["CPM_GOVUK_VIEW_ID"] = @cpm_govuk_view_id
      end

      context "Get number of page views from the Google Analytics Reporting API" do
        let(:page_views_request) do
          {
            report_requests: [
              {
                metrics: [
                  {
                    expression: "ga:pageViews"
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
          }.with_indifferent_access
        end

        it "builds the requests body with default arguments" do
          request = PageViewsRequest.new.build(["/check-uk-visa"])

          expect(request.as_json).to include(page_views_request)
        end

        it "builds the requests body with supplied arguments" do
          page_views_request[:report_requests][0][:date_ranges][0][:start_date] = "2016/11/22"
          page_views_request[:report_requests][0][:date_ranges][0][:end_date] = "2016/12/22"

          request = PageViewsRequest.new.build(
            ["/check-uk-visa"],
            start_date: "2016/11/22",
            end_date: "2016/12/22")

          expect(request.as_json).to include(page_views_request)
        end
      end
    end
  end
end
