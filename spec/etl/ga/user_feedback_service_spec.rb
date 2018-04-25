require 'google/apis/analyticsreporting_v4'

RSpec.describe GA::UserFeedbackService do
  include GoogleAnalyticsRequests

  subject { GA::UserFeedbackService.new }

  let(:google_client) { double('client') }
  before { allow(subject).to receive(:client).and_return(google_client) }

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

    before do
      allow(subject.client).to receive(:fetch_all) do
        [
          build_report_data(
            build_report_row(dimensions: %w(/foo ffNoClick), metrics: %w(10))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/foo ffYesClick), metrics: %w(7))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/bar ffYesClick), metrics: %w(3))
          ),
          build_report_data(
            build_report_row(dimensions: %w(/bar ffNoClick), metrics: %w(13))
          ),
        ]
      end
    end

    context 'when #find_in_batches is called with a block' do
      it 'yield successive report data if all actions are present' do
        arg1 = [
          a_hash_including(
            'page_path' => '/foo',
            'is_this_useful_yes' => 7,
            'is_this_useful_no' => 10,
            'date' => '2018-02-20',
          ),
        ]
        arg2 = [
          a_hash_including(
            'page_path' => '/bar',
            'is_this_useful_yes' => 3,
            'is_this_useful_no' => 13,
            'date' => '2018-02-20',
          )
        ]
        expect { |probe| subject.find_in_batches(date: date, batch_size: 1, &probe) }
          .to yield_successive_args(arg1, arg2)
      end

      it 'yields successive report data if some actions are missing' do
        allow(subject.client).to receive(:fetch_all) do
          [
            build_report_data(
              build_report_row(dimensions: %w(/foo ffNoClick), metrics: %w(10))
            ),
            build_report_data(
              build_report_row(dimensions: %w(/bar ffYesClick), metrics: %w(3))
            ),
          ]
        end
        arg1 = [
          a_hash_including(
            'page_path' => '/foo',
            'is_this_useful_yes' => nil,
            'is_this_useful_no' => 10,
            'date' => '2018-02-20',
          ),
        ]
        arg2 = [
          a_hash_including(
            'page_path' => '/bar',
            'is_this_useful_yes' => 3,
            'is_this_useful_no' => nil,
            'date' => '2018-02-20',
          )
        ]
        expect { |probe| subject.find_in_batches(date: date, batch_size: 1, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end
  end
end
