require "gds-api-adapters"
# require "traceable"

RSpec.describe Etl::GA::InternalSearchProcessor do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  context "When the base_path matches the GA path" do
    before { allow(Etl::GA::InternalSearchService).to receive(:find_in_batches).and_yield(ga_response) }

    it "updates the facts with GA metrics" do
      edition1 = create :edition, date: "2018-02-20", base_path: "/Path1"
      # We have some mixed case paths so we need them to match the lowercase ones in GA

      fact1 = create :metric, edition: edition1, date: "2018-02-20"
      edition2 = create :edition, base_path: "/path2", date: "2018-02-20"
      fact2 = create :metric, edition: edition2, date: "2018-02-20"

      described_class.process(date:)

      expect(fact1.reload).to have_attributes(searches: 1)
      expect(fact2.reload).to have_attributes(searches: 2)
    end

    it "does not update metrics for other days" do
      create :edition, base_path: "/path1", date: "2018-02-20"
      fact1 = create :metric, date: "2018-02-20", searches: 20

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(searches: 20)
    end

    it "does not update metrics for other items" do
      edition = create :edition, base_path: "/non-matching-path", date: "2018-02-20"
      fact = create :metric, edition:, date: "2018-02-20", searches: 99

      described_class.process(date:)

      expect(fact.reload).to have_attributes(searches: 99)
    end

    it "deletes events after updating facts metrics" do
      create :ga_event, :with_searches, date: date - 1, page_path: "/path1"

      described_class.process(date:)

      expect(Events::GA.count).to eq(0)
    end

    context "when there are events from other days" do
      before do
        create :ga_event, :with_searches, date: date - 1, page_path: "/path1"
        create :ga_event, :with_searches, date: date - 2, page_path: "/path1"
      end

      it "only updates metrics for the current day" do
        edition = create :edition, base_path: "/path1", date: "2018-02-20"
        fact1 = create :metric, edition:, date: "2018-02-20"

        described_class.process(date:)

        expect(fact1.reload).to have_attributes(searches: 1)
      end

      it "deletes events after updating facts metrics" do
        expect(Events::GA.count).to eq(2)

        described_class.process(date:)

        expect(Events::GA.count).to eq(0)
      end
    end
  end

  it_behaves_like "traps and logs errors in process", Etl::GA::InternalSearchService, :find_in_batches

private

  def ga_response
    [
      {
        "page_path" => "/path1",
        "searches" => 1,
        "date" => "2018-02-20",
        "process_name" => "searches",
      },
      {
        "page_path" => "/path2",
        "searches" => 2,
        "date" => "2018-02-20",
        "process_name" => "searches",
      },
    ]
  end

  def ga_response_with_govuk_prefix
    [
      {
        "page_path" => "/https://www.gov.uk/path1",
        "searches" => 1,
        "date" => "2018-02-20",
        "process_name" => "searches",
      },
      {
        "page_path" => "/path2",
        "searches" => 2,
        "date" => "2018-02-20",
        "process_name" => "searches",
      },
    ]
  end
end
