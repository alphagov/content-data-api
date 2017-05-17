require 'google/apis/analyticsreporting_v4'

RSpec.describe GoogleAnalyticsService do
  subject { GoogleAnalyticsService.new }

  let(:google_client) { double('client') }
  before { allow(subject).to receive(:client).and_return(google_client) }


  describe '#page_views' do
    it 'raises an exception when another type is supplied, instead of an Array' do
      expect { subject.page_views('/marriage-abroad') }.to raise_error("base_paths isn't an array")
    end

    it 'returns a hash containing the page views' do
      google_response = GoogleAnalytics::PageViewsResponseFactory.build(
        [
          {
            base_path: '/path-1',
            one_month_page_views: 5,
            six_months_page_views: 60,
          }
        ]
      )
      allow(google_client).to receive(:batch_get_reports).and_return(google_response)

      response = subject.page_views(%w(/path-1))
      expect(response).to eq([
        {
          base_path: '/path-1',
          one_month_page_views: 5,
          six_months_page_views: 60,
        }
      ])
    end
  end
end
