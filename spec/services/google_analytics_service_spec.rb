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
      google_response = GoogleAnalyticsFactory.build_page_views_response(
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

    it 'does not process arrays consisting solely of nil values' do
      base_paths = [nil, nil]

      expect_any_instance_of(GoogleAnalytics::Requests::PageViewsRequest).to_not receive(:build)

      response = subject.page_views(base_paths)
      expect(response).to eq([])
    end

    it 'returns an empty array if the returns rows are nil' do
      google_response = GoogleAnalyticsFactory.build_page_views_response(nil)
      allow(google_client).to receive(:batch_get_reports).and_return(google_response)

      response = subject.page_views(%w(/a-path-with-no-pageviews))
      expect(response).to eq([])
    end
  end

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

    before do
      allow(subject.client).to receive(:fetch_all) do
        [
          build_report_data(
            build_report_row(dimensions: %w(/foo), metrics: %w(1 1))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/bar), metrics: %w(2 2))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/cool), metrics: %w(3 3))
          ),
        ]
      end
    end

    context 'when called with a block' do
      it 'should yield successive report data' do
        arg1 = [
          a_hash_including(
            'ga:pagePath' => '/foo',
            'ga:pageviews' => 1,
            'ga:uniquePageviews' => 1,
            'date' => '2018-02-20',
          ),
          a_hash_including(
            'ga:pagePath' => '/bar',
            'ga:pageviews' => 2,
            'ga:uniquePageviews' => 2,
            'date' => '2018-02-20',
          )
        ]
        arg2 = [
          a_hash_including(
            'ga:pagePath' => '/cool',
            'ga:pageviews' => 3,
            'ga:uniquePageviews' => 3,
            'date' => '2018-02-20',
          )
        ]

        expect { |probe| subject.find_in_batches(date: date, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end

    private

    def build_report_data(*report_rows)
      Google::Apis::AnalyticsreportingV4::ReportData.new(rows: report_rows)
    end

    def build_report_row(dimensions:, metrics:)
      Google::Apis::AnalyticsreportingV4::ReportRow.new(
        dimensions: dimensions,
        metrics: metrics.map do |metric|
          Google::Apis::AnalyticsreportingV4::DateRangeValues.new(
            values: Array(metric)
          )
        end
      )
    end
  end
end
