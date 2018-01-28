RSpec.describe GoogleAnalytics::Responses::PageviewsResponse do
  describe '#parse' do
    context 'a response with two base paths' do
      subject(:page_views) { described_class.new.parse(response) }

      let(:response) do
        GoogleAnalyticsFactory
          .build_pageviews_response(
            [
              {
                base_path: "/check-uk-visa",
                page_views: 400,
                unique_page_views: 300,
              },
              {
                base_path: "/marriage-abroad",
                page_views: 500,
                unique_page_views: 400,
              },
            ]
          )
      end

      it "returns the number of page views for content items" do
        expect(page_views).to contain_exactly(
          Hash[base_path: "/check-uk-visa", page_views: 400, unique_page_views: 300],
          Hash[base_path: "/marriage-abroad", page_views: 500, unique_page_views: 400]
        )
      end
    end
  end
end
