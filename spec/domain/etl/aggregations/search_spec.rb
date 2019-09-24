RSpec.describe Etl::Aggregations::Search do
  subject { described_class }

  before do
    allow(Aggregations::SearchLastThirtyDays).to receive(:refresh)
    allow(Aggregations::SearchLastMonth).to receive(:refresh)
    allow(Aggregations::SearchLastThreeMonths).to receive(:refresh)
    allow(Aggregations::SearchLastSixMonths).to receive(:refresh)
    allow(Aggregations::SearchLastTwelveMonths).to receive(:refresh)
  end

  it "refreshes materialized view for: last thirty days" do
    expect(Aggregations::SearchLastThirtyDays).to receive(:refresh)

    described_class.process
  end

  it "refreshes materialized view for: last month" do
    expect(Aggregations::SearchLastMonth).to receive(:refresh)

    described_class.process
  end

  it "refreshes materialized view for: last three months" do
    expect(Aggregations::SearchLastThreeMonths).to receive(:refresh)

    described_class.process
  end

  it "refreshes materialized view for: last six months" do
    expect(Aggregations::SearchLastSixMonths).to receive(:refresh)

    described_class.process
  end

  it "refreshes materialized view for: last twelve months" do
    expect(Aggregations::SearchLastTwelveMonths).to receive(:refresh)

    described_class.process
  end
end
