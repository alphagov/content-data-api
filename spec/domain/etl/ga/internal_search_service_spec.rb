RSpec.describe Etl::GA::InternalSearchService do
  subject { Etl::GA::InternalSearchService }

  let(:google_client) { instance_double(Google::Cloud::Bigquery::Project) }
  let(:results) { instance_double(Google::Cloud::Bigquery::Data) }

  before do
    allow(Etl::GA::Bigquery).to receive(:build).and_return(google_client)
    allow(google_client).to receive(:query).and_return(results)

    allow(results).to receive(:all).and_return([
      { "page_path" => "/foo", "searches" => 1, "date" => "2018-02-20" },
      { "page_path" => "/bar", "searches" => 2, "upviews" => 2, "date" => "2018-02-20" },
      { "page_path" => "/cool", "searches" => 3, "upviews" => 3, "date" => "2018-02-20" },
    ])
  end

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

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

      it "includes the process name" do
        arg1 = [
          a_hash_including("process_name" => "searches"),
          a_hash_including("process_name" => "searches"),
        ]
        arg2 = [
          a_hash_including("process_name" => "searches"),
        ]
        expect { |probe| subject.find_in_batches(date:, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end
  end
end
