RSpec.describe Monitor::Aggregations do
  around do |example|
    Timecop.freeze(Date.new(2018, 3, 15)) { example.run }
  end

  let(:yesterday) { '2018-03-14' }

  before { allow(GovukStatsd).to receive(:count) }

  it 'sends StatsD counter for all the aggregations' do
    expect(GovukStatsd).to receive(:count).with("monitor.aggregations.all", 2)

    create_list :monthly_metric, 2

    subject.run
  end

  it 'sends StatsD counter for `daily` metrics' do
    expect(GovukStatsd).to receive(:count).with("monitor.aggregations.current", 3)

    create_list :monthly_metric, 2, month: '2018-01'
    create_list :monthly_metric, 3, month: '2018-03'

    subject.run
  end

  describe 'exception thrown by during processing' do
    let(:error) { StandardError.new }
    before do
      allow(GovukError).to receive(:notify)
      allow(::Aggregations::MonthlyMetric).to receive(:count).and_raise(error)
    end

    it 'traps and logs the error to Sentry' do
      expect { subject.run }.not_to raise_error
      expect(GovukError).to have_received(:notify).with(error)
    end
  end
end
