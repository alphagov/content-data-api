RSpec.describe Monitor::Facts do
  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:two_days_ago) { "2018-01-13" }

  before { allow(GovukStatsd).to receive(:count) }

  it "sends StatsD counter for facts metrics" do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.all_metrics", 2)

    create_list :metric, 2

    subject.run
  end

  it "sends StatsD counter for `daily` metrics" do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.daily_metrics", 1)

    create :metric, date: two_days_ago

    subject.run
  end

  it "sends StatsD counter for facts editions" do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.all_editions", 2)

    create :edition, date: two_days_ago, base_path: "/foo"

    subject.run
  end

  it "sends StatsD counter for `daily` editions" do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.daily_editions", 1)

    create :edition, date: two_days_ago, base_path: "/foo"

    subject.run
  end

  describe "exception thrown by during processing" do
    let(:error) { StandardError.new }
    before do
      allow(GovukError).to receive(:notify)
      allow(Facts::Metric).to receive(:count).and_raise(error)
    end

    it "traps and logs the error to Sentry" do
      expect { subject.run }.not_to raise_error
      expect(GovukError).to have_received(:notify).with(error)
    end
  end

  it_behaves_like "traps and logs errors in run", Facts::Metric, :count
end
