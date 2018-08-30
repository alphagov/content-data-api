RSpec.describe Monitor::Facts do
  include ItemSetupHelpers

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { '2018-01-14' }

  before { allow(GovukStatsd).to receive(:count) }

  it 'sends the total number of facts metrics' do
    expect(GovukStatsd).to receive(:count).with("monitor.facts.all_metrics", 2)

    create_list :metric, 2

    subject.run
  end

end
