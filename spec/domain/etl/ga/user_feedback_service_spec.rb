RSpec.describe Etl::GA::UserFeedbackService do
  subject { Etl::GA::UserFeedbackService }

  let(:google_client) { instance_double(Google::Cloud::Bigquery::Project) }
  let(:results) { instance_double(Google::Cloud::Bigquery::Data) }

  before do
    allow(Etl::GA::Bigquery).to receive(:build).and_return(google_client)
    allow(google_client).to receive(:query).and_return(results)

    allow(results).to receive(:all).and_return([
      { "page_path" => "/foo", "useful_yes" => 1, "useful_no" => 1, "date" => "2024-02-20" },
      { "page_path" => "/bar", "useful_yes" => 2, "useful_no" => 2, "date" => "2024-02-20" },
      { "page_path" => "/cool", "useful_yes" => 3, "useful_no" => 3, "date" => "2024-02-20" },
    ])
  end

  describe "#find_in_batches" do
    let(:date) { Date.new(2024, 2, 20) }

    context "when #find_in_batches is called with a block" do
      it "yield successive report data if all actions are present" do
        arg1 = [
          a_hash_including("page_path" => "/foo", "useful_yes" => 1, "useful_no" => 1, "date" => "2024-02-20"),
          a_hash_including("page_path" => "/bar", "useful_yes" => 2, "useful_no" => 2, "date" => "2024-02-20"),
        ]
        arg2 = [
          a_hash_including("page_path" => "/cool", "useful_yes" => 3, "useful_no" => 3, "date" => "2024-02-20"),
        ]

        expect { |probe| subject.find_in_batches(date:, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end

      it "includes process name" do
        arg1 = [
          a_hash_including("process_name" => "user_feedback"),
          a_hash_including("process_name" => "user_feedback"),
        ]
        arg2 = [
          a_hash_including("process_name" => "user_feedback"),
        ]
        expect { |probe| subject.find_in_batches(date:, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end
  end
end
