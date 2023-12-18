require "gds-api-adapters"

RSpec.describe Etl::Main::MainProcessor do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  around do |example|
    Timecop.freeze(date) { example.run }
  end

  before do
    allow(Etl::GA::ViewsAndNavigationProcessor).to receive(:process).and_return(true)
    allow(Etl::GA::UserFeedbackProcessor).to receive(:process).and_return(true)
    allow(Etl::GA::InternalSearchProcessor).to receive(:process).and_return(true)
    allow(Etl::Feedex::Processor).to receive(:process).and_return(true)
    allow(Etl::Main::MetricsProcessor).to receive(:process).and_return(true)
    allow(Monitor::Etl).to receive(:run).and_return(true)

    allow(Etl::Aggregations::Monthly).to receive(:process)
    allow(Etl::Aggregations::Search).to receive(:process)
  end

  describe "re-running the same day" do
    it "deletes existing metrics if they already exist for that day" do
      date = create(:dimensions_date, date: Time.zone.today - 2)
      existing_metric = create(:metric, dimensions_date: date)

      expect { subject.process }.not_to raise_error
      expect(Facts::Metric.where(id: existing_metric.id).count).to eq(0)
    end

    it "does not raise errors otherwise" do
      create(:dimensions_date, date: Time.zone.today - 2)

      expect { subject.process }.to_not raise_error
    end
  end

  it "creates a Metrics fact per content item" do
    subject.process

    expect(Etl::Main::MetricsProcessor).to have_received(:process).with(date: Date.new(2018, 2, 18))
  end

  it "update GA metrics in the Facts table" do
    expect(Etl::GA::ViewsAndNavigationProcessor).to receive(:process).with(date: Date.new(2018, 2, 18))
    expect(Etl::GA::UserFeedbackProcessor).to receive(:process).with(date: Date.new(2018, 2, 18))
    expect(Etl::GA::InternalSearchProcessor).to receive(:process).with(date: Date.new(2018, 2, 18))

    subject.process
  end

  it "update Feedex metrics in the Facts table" do
    expect(Etl::Feedex::Processor).to receive(:process).with(date: Date.new(2018, 2, 18))

    subject.process
  end

  it "handles processor failures" do
    allow(Etl::GA::ViewsAndNavigationProcessor).to receive(:process).and_return(false)

    expect(subject.process).to be false
  end

  describe "Aggregations" do
    context "when two days before" do
      it "calculate the monthly aggregations" do
        expect(Etl::Aggregations::Monthly).to receive(:process).with(date: Date.new(2018, 2, 18))

        subject.process
      end

      it "calculates the search aggregations" do
        expect(Etl::Aggregations::Search).to receive(:process)

        subject.process
      end
    end

    context "when not two days before" do
      it "does not calculate the monthly aggregations" do
        expect(Etl::Aggregations::Monthly).to_not receive(:process).with(date: Date.new(2018, 2, 17))

        subject.process(date: Date.new(2018, 2, 17))
      end

      it "does not calculate the monthly aggregations" do
        expect(Etl::Aggregations::Search).to_not receive(:process)

        subject.process(date: Date.new(2018, 2, 17))
      end
    end
  end

  describe "Monitoring" do
    context "two days before" do
      it "monitors ETL processes" do
        expect(Monitor::Etl).to receive(:run)

        subject.process
      end

      it "monitor Item Dimensions" do
        expect(Monitor::Dimensions).to receive(:run)

        subject.process
      end

      it "monitor Facts" do
        expect(Monitor::Facts).to receive(:run)

        subject.process
      end

      it "monitor Aggregations" do
        expect(Monitor::Aggregations).to receive(:run)

        subject.process
      end

      it "handles failures" do
        allow(Monitor::Aggregations).to receive(:run).and_return(false)

        expect(subject.process).to be false
      end
    end

    context "not two days before" do
      it "does not add ETL stats if not two days before" do
        expect(Monitor::Etl).to_not receive(:run)

        subject.process(date: Time.zone.today)
      end

      it "does not add Dimension stats if not two days before" do
        expect(Monitor::Dimensions).to_not receive(:run)

        subject.process(date: Time.zone.today)
      end

      it "does not add Facts stats if not two days before" do
        expect(Monitor::Facts).to_not receive(:run)

        subject.process(date: Time.zone.today)
      end
    end
  end

  it "can run the process for other days" do
    another_date = Date.new(2017, 12, 30)
    subject.process(date: another_date)

    expect(Etl::Main::MetricsProcessor).to have_received(:process).with(date: another_date)
    expect(Etl::GA::ViewsAndNavigationProcessor).to have_received(:process).with(date: another_date)
    expect(Etl::Feedex::Processor).to have_received(:process).with(date: another_date)
  end

  describe ".process_aggregations" do
    before do
      subject.process_aggregations(date:)
    end

    it "runs the Aggregations::Monthly process" do
      expect(Etl::Aggregations::Monthly).to have_received(:process).with(date:)
    end

    it "runs the Aggregations::Search process" do
      expect(Etl::Aggregations::Monthly).to have_received(:process)
    end
  end
end
