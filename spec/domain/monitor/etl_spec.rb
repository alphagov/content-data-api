RSpec.describe Monitor::Etl do
  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:two_days_ago) { "2018-01-13" }

  before { allow(GovukStatsd).to receive(:count) }

  Metric.daily_metrics.map(&:name).each do |metric_name|
    it "sends StatsD counter for daily metric: `#{metric_name}` for day before yesterday" do
      expect(GovukStatsd).to receive(:count).with("monitor.etl.daily.#{metric_name}", 10)

      create :metric, date: two_days_ago, metric_name => 10
      subject.run
    end
  end

  Metric.edition_metrics.map(&:name).each do |metric_name|
    it "sends StatsD counter for edition metric `#{metric_name}` for day before yesterday" do
      expect(GovukStatsd).to receive(:count).with("monitor.etl.edition.#{metric_name}", 10)

      edition = create :edition, date: two_days_ago, facts: { metric_name => 10 }
      create :metric, edition:, date: two_days_ago
      subject.run
    end
  end

  it_behaves_like "traps and logs errors in run", Metric, :edition_metrics
end
