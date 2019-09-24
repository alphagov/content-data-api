RSpec.describe Monitor::Aggregations do
  around do |example|
    Timecop.freeze(Date.new(2018, 3, 15)) { example.run }
  end

  let(:yesterday) { "2018-03-14" }

  before { allow(GovukStatsd).to receive(:count) }

  it "sends StatsD counter for all the aggregations" do
    expect(GovukStatsd).to receive(:count).with("monitor.aggregations.all", 2)

    create_list :monthly_metric, 2

    subject.run
  end

  it "sends StatsD counter for `daily` metrics" do
    expect(GovukStatsd).to receive(:count).with("monitor.aggregations.current", 3)

    create_list :monthly_metric, 2, month: "2018-01"
    create_list :monthly_metric, 3, month: "2018-03"

    subject.run
  end

  it_behaves_like "traps and logs errors in run", ::Aggregations::MonthlyMetric, :count
end
