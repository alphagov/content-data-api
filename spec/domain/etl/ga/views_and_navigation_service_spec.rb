RSpec.describe Etl::GA::ViewsAndNavigationService do
  subject { Etl::GA::ViewsAndNavigationService }

  let(:google_client) { instance_double(Google::Cloud::Bigquery::Project) }
  let(:results) { instance_double(Google::Cloud::Bigquery::Data) }

  before do
    allow(Etl::GA::Bigquery).to receive(:build).and_return(google_client)
    allow(google_client).to receive(:query).and_return(results)

    allow(results).to receive(:all).and_return([
      { "page_path" => "/foo", "pviews" => 1, "upviews" => 1, "date" => "2018-02-20" },
      { "page_path" => "/bar", "pviews" => 2, "upviews" => 2, "date" => "2018-02-20" },
      { "page_path" => "/cool", "pviews" => 3, "upviews" => 3, "date" => "2018-02-20" },
    ])
  end

  describe "#find_in_batches" do
    let(:date) { Date.new(2018, 2, 20) }

    context "when #find_in_batches is called with a block" do
      it "yields successive report data" do
        arg1 = [
          a_hash_including("page_path" => "/foo", "pviews" => 1, "upviews" => 1, "date" => "2018-02-20"),
          a_hash_including("page_path" => "/bar", "pviews" => 2, "upviews" => 2, "date" => "2018-02-20"),
        ]
        arg2 = [
          a_hash_including("page_path" => "/cool", "pviews" => 3, "upviews" => 3, "date" => "2018-02-20"),
        ]

        expect { |probe| subject.find_in_batches(date:, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end

      it "yields successive report data including the process name" do
        arg1 = [
          a_hash_including("process_name" => "views"),
          a_hash_including("process_name" => "views"),
        ]
        arg2 = [
          a_hash_including("process_name" => "views"),
        ]

        expect { |probe| subject.find_in_batches(date:, batch_size: 2, &probe) }
          .to yield_successive_args(arg1, arg2)
      end
    end

    context "when report data has page path with long query strings" do
      it "should ignore page" do
        allow(results).to receive(:all) do
          [
            { "page_path" => "/foo", "pviews" => 1, "upviews" => 1, "date" => "2018-02-20" },
            { "page_path" => path_with_long_query, "pviews" => 2, "upviews" => 2, "date" => "2018-02-20" },
            { "page_path" => long_path, "pviews" => 3, "upviews" => 3, "date" => "2018-02-20" },
          ]
        end

        arg = [
          a_hash_including("page_path" => "/foo", "pviews" => 1, "upviews" => 1, "date" => "2018-02-20"),
        ]

        expect { |probe| subject.find_in_batches(date:, batch_size: 1, &probe) }
          .to yield_with_args(arg)
      end
    end

    context "when report data has page path with an invalid URI" do
      it "should ignore page" do
        allow(results).to receive(:all) do
          [
            { "page_path" => "/foo", "pviews" => 1, "upviews" => 1, "date" => "2018-02-20" },
            { "page_path" => path_with_invalid_uri, "pviews" => 2, "upviews" => 2, "date" => "2018-02-20" },
          ]
        end

        arg = [
          a_hash_including("page_path" => "/foo", "pviews" => 1, "upviews" => 1, "date" => "2018-02-20"),
        ]

        expect { |probe| subject.find_in_batches(date:, batch_size: 1, &probe) }
          .to yield_with_args(arg)
      end
    end
  end

private

  def path_with_long_query
    "/foo?q=".concat("a" * 1600)
  end

  def long_path
    "/foo".concat("o" * described_class::PAGE_PATH_LENGTH_LIMIT)
  end

  def path_with_invalid_uri
    "/foo#}&sector_business_area[]=accommodation"
  end
end
