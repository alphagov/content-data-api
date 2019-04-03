RSpec.describe Monitor::Dimensions do
  around do |example|
    Timecop.freeze(Date.new(2018, 1, 15)) { example.run }
  end

  let(:yesterday) { '2018-01-14' }

  before { allow(GovukStatsd).to receive(:count) }

  it 'sends StatsD counter of base_paths' do
    expect(GovukStatsd).to receive(:count).with("monitor.dimensions.base_paths", 2)

    create_list :edition, 2

    subject.run
  end

  it 'sends StatsD counter of `live` base_paths' do
    expect(GovukStatsd).to receive(:count).with("monitor.dimensions.live_base_paths", 1)

    create :edition, base_path: '/foo', live: true
    create :edition, base_path: '/bar', live: false

    subject.run
  end

  it 'sends StatsD counter of content_items' do
    expect(GovukStatsd).to receive(:count).with("monitor.dimensions.content_items", 1)

    edition1 = create :edition, content_id: 'id1', base_path: '/foo'
    create :edition, content_id: 'id1', base_path: '/bar', replaces: edition1

    subject.run
  end

  it 'sends StatsD counter of `live` content_items' do
    expect(GovukStatsd).to receive(:count).with("monitor.dimensions.live_content_items", 1)

    edition1 = create :edition, content_id: 'id1', base_path: '/foo'
    create :edition, content_id: 'id1', base_path: '/bar', replaces: edition1
    create :edition, content_id: 'id2', base_path: '/other', live: false
    subject.run
  end

  it_behaves_like 'traps and logs errors in run', Dimensions::Edition, :live
end
