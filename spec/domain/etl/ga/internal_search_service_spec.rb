require "google/apis/analyticsreporting_v4"

RSpec.describe Etl::GA::InternalSearchService do
  include GoogleAnalyticsRequests

  subject { Etl::GA::InternalSearchService }

  let(:google_client) { instance_double(Google::Apis::AnalyticsreportingV4::AnalyticsReportingService) }
  before { expect(Etl::GA::Client).to receive(:build).and_return(google_client) }

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

    before do
      allow(google_client).to receive(:fetch_all) do
        [
          build_report_data(
            build_report_row(dimensions: %w[/foo], metrics: %w[1]),
          ),
          build_report_data(
            build_report_row(dimensions: %w[/bar], metrics: %w[2]),
          ),
          build_report_data(
            build_report_row(dimensions: %w[/cool], metrics: %w[3]),
          ),
        ]
      end
    end

    context "when #find_in_batches is called with a block" do
      it "yields successive report data" do
        arg1 = [
          a_hash_including(
            "page_path" => "/foo",
            "searches" => 1,
            "date" => "2018-02-20",
          ),
          a_hash_including(
            "page_path" => "/bar",
            "searches" => 2,
            "date" => "2018-02-20",
          ),
        ]

        arg2 = [
          a_hash_including(
            "page_path" => "/cool",
            "searches" => 3,
            "date" => "2018-02-20",
          ),
        ]

        expect { |probe| subject.find_in_batches(date:, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end
  end
end
