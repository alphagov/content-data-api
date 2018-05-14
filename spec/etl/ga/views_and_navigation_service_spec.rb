require 'google/apis/analyticsreporting_v4'

RSpec.describe GA::ViewsAndNavigationService do
  include GoogleAnalyticsRequests

  subject { GA::ViewsAndNavigationService }

  let(:google_client) { double('client') }
  before { allow_any_instance_of(GA::ViewsAndNavigationService).to receive(:client).and_return(google_client) }

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

    before do
      allow(google_client).to receive(:fetch_all) do
        [
          build_report_data(
            build_report_row(dimensions: %w(/foo), metrics: %w(1 1 1 1 1 1))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/bar), metrics: %w(2 2 2 2 2 2))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/cool), metrics: %w(3 3 3 3 3 3))
          ),
        ]
      end
    end

    context 'when #find_in_batches is called with a block' do
      it 'yields successive report data' do
        arg1 = [
          a_hash_including(
            'page_path' => '/foo',
            'pageviews' => 1,
            'unique_pageviews' => 1,
            'entrances' => 1,
            'exits' => 1,
            'bounce_rate' => 1,
            'avg_time_on_page' => 1,
            'date' => '2018-02-20',
          ),
          a_hash_including(
            'page_path' => '/bar',
            'pageviews' => 2,
            'unique_pageviews' => 2,
            'entrances' => 2,
            'exits' => 2,
            'bounce_rate' => 2,
            'avg_time_on_page' => 2,
            'date' => '2018-02-20',
          )
        ]
        arg2 = [
          a_hash_including(
            'page_path' => '/cool',
            'pageviews' => 3,
            'unique_pageviews' => 3,
            'entrances' => 3,
            'exits' => 3,
            'bounce_rate' => 3,
            'avg_time_on_page' => 3,
            'date' => '2018-02-20',
          )
        ]

        expect { |probe| subject.find_in_batches(date: date, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end
  end
end
