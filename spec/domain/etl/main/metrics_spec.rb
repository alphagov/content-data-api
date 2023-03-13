RSpec.describe Etl::Main::MetricsProcessor do
  let(:date) { Date.new(2018, 3, 15) }

  subject { described_class.new(date:) }

  it "creates a Metrics fact per content item" do
    create :edition, live: true
    item = create(:edition, live: true, content_id: "cid1")

    expect(subject.process).to be true

    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.find_by(dimensions_edition: item)).to have_attributes(
      dimensions_date: Dimensions::Date.find_existing_or_create(Date.new(2018, 3, 15)),
      dimensions_edition: item,
    )
  end

  it "only create a Metrics Fact entry for Content Items with live = `true`" do
    create(:edition, live: true, content_id: "cid1")
    create(:edition, live: false, content_id: "cid1")

    expect(subject.process).to be true

    expect(Facts::Metric.count).to eq(1)
  end

  it "reports failure" do
    allow(subject).to receive(:create_metrics).and_raise

    expect(subject.process).to be false
  end
end
