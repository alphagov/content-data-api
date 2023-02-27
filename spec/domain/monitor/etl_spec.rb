RSpec.describe Monitor::Etl do
  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { "2018-01-14" }

  before { allow(GovukStatsd).to receive(:count) }

  Metric.daily_metrics.map(&:name).each do |metric_name|
    it "sends StatsD counter for daily metric: `#{metric_name}` for previous day" do
      expect(GovukStatsd).to receive(:count).with("monitor.etl.daily.#{metric_name}", 10)

      create :metric, date: yesterday, metric_name => 10
      subject.run
    end
  end

  Metric.edition_metrics.map(&:name).each do |metric_name|
    it "sends StatsD counter for edition metric `#{metric_name}` for previous day" do
      expect(GovukStatsd).to receive(:count).with("monitor.etl.edition.#{metric_name}", 10)

      edition = create :edition, date: yesterday, facts: { metric_name => 10 }
      create :metric, edition:, date: yesterday
      subject.run
    end
  end

  it_behaves_like "traps and logs errors in run", Metric, :edition_metrics
end
