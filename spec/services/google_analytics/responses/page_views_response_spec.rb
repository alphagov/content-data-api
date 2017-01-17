require 'rails_helper'

module GoogleAnalytics
  module Responses
    RSpec.describe PageViewsResponse do
      let(:two_page_views_response) do
        GoogleAnalytics::PageViewsResponseFactory.build([
          {
            base_path: "/check-uk-visa",
            page_views: 400
          },
          {
            base_path: "/marriage-abroad",
            page_views: 500
          }
        ])
      end

      it "returns the number of page views for content items" do
        page_views = PageViewsResponse.new.parse(two_page_views_response)
        expected_response = [
          {
            base_path: "/check-uk-visa",
            page_views: 400
          },
          {
            base_path: "/marriage-abroad",
            page_views: 500
          }
        ]

        expect(page_views).to eq(expected_response)
      end
    end
  end
end
