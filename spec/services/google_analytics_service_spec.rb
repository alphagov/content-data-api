require 'google/apis/analyticsreporting_v4'

RSpec.describe GA::Service do
  subject { GA::Service.new }

  let(:google_client) { double('client') }
  before { allow(subject).to receive(:client).and_return(google_client) }

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

    context 'when #find_in_batches is called with a block' do
      it 'should yield successive report data' do
        arg1 = [
          a_hash_including(
            'page_path' => '/foo',
            'pageviews' => 1,
            'unique_pageviews' => 1,
            'date' => '2018-02-20',
          ),
          a_hash_including(
            'page_path' => '/bar',
            'pageviews' => 2,
            'unique_pageviews' => 2,
            'date' => '2018-02-20',
          )
        ]
        arg2 = [
          a_hash_including(
            'page_path' => '/cool',
            'pageviews' => 3,
            'unique_pageviews' => 3,
            'date' => '2018-02-20',
          )
        ]

        expect { |probe| subject.find_in_batches(date: date, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end

    describe "#find_user_feedback_in_batches" do
      let(:date) { Date.new(2018, 2, 20) }

      before do
        allow(subject.client).to receive(:fetch_all) do
          [
            build_report_data(
              build_report_row(dimensions: %w(/foo ffNoClick), metrics: %w(10))
            ),
            build_report_data(
              build_report_row(dimensions: %w(/foo ffYesClick), metrics: %w(2))
            ),
            build_report_data(
              build_report_row(dimensions: %w(/bar ffNoClick), metrics: %w(3))
            ),
            build_report_data(
              build_report_row(dimensions: %w(/bar ffYesClick), metrics: %w(44))
            ),
          ]
        end
      end

      context 'when #find_in_batches is called with a block' do
        it 'should yield successive report data' do
          arg1 = [
            a_hash_including(
              'page_path' => '/foo',
              'is_this_useful_yes' => 2,
              'is_this_useful_no' => 10,
              'date' => '2018-02-20',
            ),
          ]
          arg2 = [
            a_hash_including(
              'page_path' => '/cool',
              'is_this_useful_yes' => 44,
              'is_this_useful_no' => 3,
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
