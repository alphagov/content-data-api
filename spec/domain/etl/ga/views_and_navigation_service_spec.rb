require 'google/apis/analyticsreporting_v4'

RSpec.describe Etl::GA::ViewsAndNavigationService do
  include GoogleAnalyticsRequests

  subject { Etl::GA::ViewsAndNavigationService }

  let(:google_client) { instance_double(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService) }
  before { expect(Etl::GA::Client).to receive(:build).and_return(google_client) }

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

    before do
      allow(google_client).to receive(:fetch_all) do
        [
          build_report_data(
            build_report_row(dimensions: %w(/foo), metrics: %w(1 1 1 1 1 1 1 1))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/bar), metrics: %w(2 2 2 2 2 2 2 2))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/cool), metrics: %w(3 3 3 3 3 3 3 3))
          ),
        ]
      end
    end

    context 'when #find_in_batches is called with a block' do
      it 'yields successive report data' do
        arg1 = [
          a_hash_including(
            'page_path' => '/foo',
            'pviews' => 1,
            'upviews' => 1,
            'entrances' => 1,
            'exits' => 1,
            'bounce_rate' => 1,
            'avg_page_time' => 1,
            'bounces' => 1,
            'page_time' => 1,
            'date' => '2018-02-20',
          ),
          a_hash_including(
            'page_path' => '/bar',
            'pviews' => 2,
            'upviews' => 2,
            'entrances' => 2,
            'exits' => 2,
            'bounce_rate' => 2,
            'avg_page_time' => 2,
            'bounces' => 2,
            'page_time' => 2,
            'date' => '2018-02-20',
          )
        ]
        arg2 = [
          a_hash_including(
            'page_path' => '/cool',
            'pviews' => 3,
            'upviews' => 3,
            'entrances' => 3,
            'exits' => 3,
            'bounce_rate' => 3,
            'avg_page_time' => 3,
            'bounces' => 3,
            'page_time' => 3,
            'date' => '2018-02-20',
          )
        ]

        expect { |probe| subject.find_in_batches(date: date, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end
  end
end
