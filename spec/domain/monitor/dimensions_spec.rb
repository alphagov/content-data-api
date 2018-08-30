RSpec.describe Monitor::Dimensions do
  include ItemSetupHelpers

  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { '2018-01-14' }

  before { allow(GovukStatsd).to receive(:count) }

  it 'sends the total number of base_paths' do
    expect(GovukStatsd).to receive(:count).with("monitor.dimensions.base_path", 2)

    create_list :dimensions_item, 2

    subject.run
  end
end
