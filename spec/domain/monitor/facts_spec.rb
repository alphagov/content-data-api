RSpec.describe Monitor::Facts do
  include ItemSetupHelpers

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { '2018-01-14' }

  before { allow(GovukStatsd).to receive(:count) }

  it 'sends StatsD counter for facts metrics' do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.all_metrics", 2)

    create_list :metric, 2

    subject.run
  end

  it 'sends StatsD counter for `daily` metrics' do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.daily_metrics", 1)

    create_metric date: Date.yesterday
    create_metric date: Date.today

    subject.run
  end

  it 'sends StatsD counter for facts editions' do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.all_editions", 2)

    create_metric date: Date.yesterday, base_path: '/foo'
    create_metric date: Date.today, base_path: '/bar'

    subject.run
  end

  it 'sends StatsD counter for `daily` editions' do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.daily_editions", 1)

    create_metric date: Date.yesterday, base_path: '/foo'
    create_metric date: Date.today, base_path: '/bar'

    subject.run
  end
end
