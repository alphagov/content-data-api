require "gds-api-adapters"
require "traceable"

RSpec.describe Etl::GA::ViewsAndNavigationProcessor do
  subject { described_class }

  let!(:edition1) { create :edition, base_path: "/Path1", live: true, date: "2018-02-20" }
  # We have some mixed case paths so we need them to match the lowercase ones in GA

  let!(:edition2) { create :edition, base_path: "/path2", live: true, date: "2018-02-20" }

  let(:date) { Date.new(2018, 2, 20) }

  context "When the base_path matches the GA path" do
    before { allow(Etl::GA::ViewsAndNavigationService).to receive(:find_in_batches).and_yield(ga_response) }

    it "update the facts with the GA metrics" do
      fact1 = create :metric, edition: edition1, date: "2018-02-20"
      fact2 = create :metric, edition: edition2, date: "2018-02-20"

      described_class.process(date:)

      expect(fact1.reload).to have_attributes(pviews: 1, upviews: 1)
      expect(fact2.reload).to have_attributes(pviews: 2, upviews: 2)
    end

    it "does not update metrics for other days" do
      fact1 = create :metric, edition: edition1, date: "2018-02-20", pviews: 20, upviews: 10

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(pviews: 20, upviews: 10)
    end

    it "does not update metrics for other items" do
      edition = create :edition, base_path: "/non-matching-path", date: "2018-02-20"
      fact = create :metric, edition:, date: "2018-02-20", pviews: 99, upviews: 90

      described_class.process(date:)

      expect(fact.reload).to have_attributes(pviews: 99, upviews: 90)
    end

    it "deletes events after updating facts metrics" do
      create(:ga_event, :with_user_feedback, date: date - 1, page_path: "/path1")

      described_class.process(date:)

      expect(Events::GA.count).to eq(0)
    end

    context "when there are events from other days" do
      before do
        create(:ga_event, :with_views, date: date - 1, page_path: "/path1")
        create(:ga_event, :with_views, date: date - 2, page_path: "/path1")
      end

      it "only updates metrics for the current day" do
        fact1 = create :metric, edition: edition1, date: "2018-02-20"

        described_class.process(date:)

        expect(fact1.reload).to have_attributes(pviews: 1, upviews: 1)
      end
    end
  end

  context "When the GA path contains the gov.uk prefix" do
    before { allow(Etl::GA::ViewsAndNavigationService).to receive(:find_in_batches).and_yield(ga_response_with_govuk_prefix) }

    context "when an event does not already exist with the same page_path" do
      it "updates the fact with the GA metrics" do
        fact1 = create :metric, edition: edition1, date: "2018-02-20"

        described_class.process(date:)

        expect(fact1.reload).to have_attributes(pviews: 1, upviews: 1)
      end
    end

    context "when an event already exists with the same page_path" do
      before do
        create(:ga_event, :with_views, date: "2018-02-20", page_path: "/path1")
      end

      it "updates the fact with the aggregated GA metrics" do
        fact1 = create :metric, edition: edition1, date: "2018-02-20"

        described_class.process(date:)

        expect(fact1.reload).to have_attributes(pviews: 11, upviews: 6)
      end

      it "does not update metrics for other days" do
        fact1 = create :metric, edition: edition1, date: "2018-02-20", pviews: 20, upviews: 10

        day_before = date - 1
        described_class.process(date: day_before)

        expect(fact1.reload).to have_attributes(pviews: 20, upviews: 10)
      end

      it "does not update metrics for other items" do
        edition = create :edition, base_path: "/non-matching-path", date: "2018-02-20"
        fact = create :metric, edition:, date: "2018-02-20", pviews: 99, upviews: 90

        described_class.process(date:)

        expect(fact.reload).to have_attributes(pviews: 99, upviews: 90)
      end

      it "deletes events after updating facts metrics" do
        described_class.process(date:)

        expect(Events::GA.count).to eq(0)
      end
    end
  end

  it_behaves_like "traps and logs errors in process", Etl::GA::ViewsAndNavigationService, :find_in_batches

private

  def ga_response
    [
      {
        "page_path" => "/path1",
        "pviews" => 1,
        "upviews" => 1,
        "date" => "2018-02-20",
        "process_name" => "views",
      },
      {
        "page_path" => "/path2",
        "pviews" => 2,
        "upviews" => 2,
        "date" => "2018-02-20",
        "process_name" => "views",
      },
    ]
  end

  def ga_response_with_govuk_prefix
    [
      {
        "page_path" => "/https://www.gov.uk/path1",
        "pviews" => 1,
        "upviews" => 1,
        "date" => "2018-02-20",
        "process_name" => "views",
      },
      {
        "page_path" => "/path2",
        "pviews" => 2,
        "upviews" => 2,
        "date" => "2018-02-20",
        "process_name" => "views",
      },
    ]
  end
end
