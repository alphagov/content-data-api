require "gds-api-adapters"

RSpec.describe Etl::Feedex::Processor do
  let(:date) { Date.new(2018, 2, 20) }
  let(:subject) { described_class }

  context "When the base_path matches the feedex path" do
    before { allow_any_instance_of(Etl::Feedex::Service).to receive(:find_in_batches).and_yield(feedex_response) }
    it "update the facts with the feedex metrics" do
      edition1 = create :edition, base_path: "/path1", date: "2018-02-20"
      fact1 = create :metric, edition: edition1, date: "2018-02-20"
      edition2 = create :edition, base_path: "/path2", date: "2018-02-20"
      fact2 = create :metric, edition: edition2, date: "2018-02-20"

      described_class.process(date:)

      expect(fact1.reload).to have_attributes(feedex: 21)
      expect(fact2.reload).to have_attributes(feedex: 11)
    end

    it "does not update metrics for other days" do
      edition1 = create :edition, base_path: "/path1", date: "2018-02-20"
      fact1 = create :metric, edition: edition1, date: "2018-02-20", feedex: 1
      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(feedex: 1)
    end

    it "does not update metrics for other items" do
      edition = create :edition, base_path: "/non-matching-path"
      fact = create :metric, edition:, date: "2018-02-20", feedex: 9

      described_class.process(date:)

      expect(fact.reload).to have_attributes(feedex: 9)
    end

    it "deletes the events that matches the base_path of an item" do
      edition = create :edition, base_path: "/path1", date: "2018-02-20"
      create :metric, edition:, date: "2018-02-20", feedex: 1

      described_class.process(date:)

      expect(Events::Feedex.where(page_path: "/path1").count).to eq(0)
    end
  end

  context "when there are events from other days" do
    before do
      allow_any_instance_of(Etl::Feedex::Service).to receive(:find_in_batches).and_yield(feedex_response)
      create(:feedex, date: date - 1, page_path: "/path1")
      create(:feedex, date: date - 2, page_path: "/path1")
    end

    it "only updates metrics for the current day" do
      edition = create :edition, base_path: "/path1"
      fact1 = create :metric, edition:, date: "2018-02-20"

      described_class.process(date:)

      expect(fact1.reload).to have_attributes(feedex: 21)
    end

    it "only deletes the events for the current day that matches" do
      edition = create :edition, base_path: "/path1"
      create :metric, edition:, date: "2018-02-20"

      described_class.process(date:)

      expect(Events::Feedex.count).to eq(3)
    end
  end

  context "when the support-api throws" do
    before do
      allow_any_instance_of(Etl::Feedex::Service).to receive(:find_in_batches).and_raise(error)
      allow(GovukError).to receive(:notify)
      described_class.process(date:)
    end

    shared_examples "all errors" do
      it "traps the error and notifies Sentry" do
        expect(GovukError).to have_received(:notify).with(error)
      end
    end

    context "a GdsApi::TimedOutException" do
      let(:error) { GdsApi::TimedOutException.new "test message" }
      it_behaves_like "all errors"
    end

    context "a GdsApi::InvalidUrl" do
      let(:error) { GdsApi::InvalidUrl.new "test message" }
      it_behaves_like "all errors"
    end

    context "a GdsApi::EndpointNotFound" do
      let(:error) { GdsApi::EndpointNotFound.new "test message" }
      it_behaves_like "all errors"
    end

    context "any other GdsApi::HTTPErrorResponse" do
      let(:error) { GdsApi::HTTPNotFound.new "test message" }
      it_behaves_like "all errors"
    end
  end

  it_behaves_like "traps and logs errors in process", Etl::Feedex::Service, :find_in_batches

private

  def feedex_response
    [
      {
        "date" => "2018-02-20",
        "page_path" => "/path1",
        "feedex_comments" => "21",
      },
      {
        "date" => "2018-02-20",
        "page_path" => "/path2",
        "feedex_comments" => "11",
      },
    ]
  end
end
