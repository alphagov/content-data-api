require "gds-api-adapters"
# require "traceable"

RSpec.describe Etl::GA::UserFeedbackProcessor do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  context "When the base_path matches the GA path" do
    before { allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response) }

    it "update the facts with the GA metrics" do
      edition1 = create :edition, base_path: "/Path1", date: "2018-02-20"
      # We have some mixed case paths so we need them to match the lowercase ones in GA

      fact1 =  create :metric, edition: edition1, date: "2018-02-20", useful_no: 1, useful_yes: 2
      edition2 = create :edition, base_path: "/path2", date: "2018-02-20"
      fact2 =  create :metric, edition: edition2, date: "2018-02-20", useful_no: 20, useful_yes: 10

      expect(fact1).to have_attributes(useful_no: 1, useful_yes: 2)
      expect(fact2).to have_attributes(useful_no: 20, useful_yes: 10)

      described_class.process(date:)

      expect(fact1.reload).to have_attributes(useful_no: 1, useful_yes: 1)
      expect(fact1.satisfaction).to be_within(0.1).of(0.5)
      expect(fact2.reload).to have_attributes(useful_no: 5, useful_yes: 10)
      expect(fact2.satisfaction).to be_within(0.1).of(0.67)
    end

    it "does not update metrics for other days" do
      edition = create :edition, base_path: "/path1", date: "2018-02-20"
      fact1 = create :metric, edition:, date: "2018-02-20", useful_no: 20, useful_yes: 10

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(useful_no: 20, useful_yes: 10)
    end

    it "does not update metrics for other items" do
      edition = create :edition, base_path: "/non-matching-path"
      fact = create :metric, edition:, date: "2018-02-20", useful_no: 99, useful_yes: 90

      described_class.process(date:)

      expect(fact.reload).to have_attributes(useful_no: 99, useful_yes: 90)
    end

    it "deletes events after updating facts metrics" do
      create(:ga_event, :with_user_feedback, date: date - 1, page_path: "/path1")

      described_class.process(date:)

      expect(Events::GA.count).to eq(0)
    end

    context "when there are events from other days" do
      before do
        create(:ga_event, :with_user_feedback, date: date - 1, page_path: "/path1")
        create(:ga_event, :with_user_feedback, date: date - 2, page_path: "/path1")
      end

      it "only updates metrics for the current day" do
        edition = create :edition, base_path: "/path1", date: "2018-02-20"
        fact1 = create :metric, edition:, date: "2018-02-20"

        described_class.process(date:)

        expect(fact1.reload).to have_attributes(useful_no: 1, useful_yes: 1)
      end
    end
  end

  context "When useful_yes/no values are received from GA" do
    let(:edition) { create :edition, base_path: "/path1", date: "2018-02-20" }
    let!(:fact) { create :metric, edition:, date: "2018-02-20" }

    it "sets `satisfaction = 1.0` with `yes: 1` and `no: 0`" do
      allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response(useful_yes: 1, useful_no: 0))
      described_class.process(date:)

      expect(fact.reload.satisfaction).to be_within(0.1).of(1.0)
    end

    it "sets `satisfaction = 0.0` with `useful_yes:0` and `no: 1`" do
      allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response(useful_yes: 0, useful_no: 1))
      described_class.process(date:)

      expect(fact.reload.satisfaction).to be_within(0.1).of(0.0)
    end

    it "set `satisfaction = nil` with `useful_yes:0` and `no: 0`" do
      allow(Etl::GA::UserFeedbackService).to receive(:find_in_batches).and_yield(ga_response(useful_yes: 0, useful_no: 0))
      described_class.process(date:)

      expect(fact.reload.satisfaction).to be_nil
    end
  end

  it_behaves_like "traps and logs errors in process", Etl::GA::UserFeedbackService, :find_in_batches

private

  def ga_response(useful_yes: 1, useful_no: 1)
    [
      {
        "page_path" => "/path1",
        "useful_yes" => useful_yes,
        "useful_no" => useful_no,
        "date" => "2018-02-20",
        "process_name" => "user_feedback",
      },
      {
        "page_path" => "/path2",
        "useful_no" => 5,
        "useful_yes" => 10,
        "date" => "2018-02-20",
        "process_name" => "user_feedback",
      },
    ]
  end
end
