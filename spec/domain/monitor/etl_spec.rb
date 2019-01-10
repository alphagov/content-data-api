RSpec.describe Monitor::Etl do
  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { '2018-01-14' }

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
      create :metric, edition: edition, date: yesterday
      subject.run
    end
  end

  describe 'exception thrown by during processing' do
    let(:error) { StandardError.new }
    before do
      allow(GovukError).to receive(:notify)
      allow(Metric).to receive(:edition_metrics).and_raise(error)
    end

    it 'traps and logs the error to Sentry' do
      expect { subject.run }.not_to raise_error
      expect(GovukError).to have_received(:notify).with(error)
    end
  end
end
