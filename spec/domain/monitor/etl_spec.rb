RSpec.describe Monitor::Etl do
  include ItemSetupHelpers

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { '2018-01-14' }

  before { allow(GovukStatsd).to receive(:count) }

  it 'sends StatsD counter for facts_metrics for previous day' do
    expect(GovukStatsd).to receive(:count).with("monitor.etl.facts_metrics", 1)

    create_metric date: yesterday
    subject.run
  end

  Metric.daily_metrics.map(&:name).each do |metric_name|
    it "sends StatsD counter for daily metric: `#{metric_name}` for previous day" do
      expect(GovukStatsd).to receive(:count).with("monitor.etl.daily.#{metric_name}", 10)

      create_metric date: yesterday, daily: { metric_name => 10 }
      subject.run
    end
  end

  Metric.edition_metrics.map(&:name).each do |metric_name|
    it "sends StatsD counter for edition metric `#{metric_name}` for previous day" do
      expect(GovukStatsd).to receive(:count).with("monitor.etl.edition.#{metric_name}", 10)

      create_metric date: yesterday, edition: { metric_name => 10 }
      subject.run
    end
  end
end
