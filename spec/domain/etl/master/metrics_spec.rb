RSpec.describe Etl::Master::MetricsProcessor do
  let(:date) { Date.new(2018, 3, 15) }

  subject { described_class.new(date: date) }

  it 'creates a Metrics fact per content item' do
    create :edition, latest: true
    item = create(:edition, latest: true, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.find_by(dimensions_edition: item)).to have_attributes(
      dimensions_date: Dimensions::Date.find_or_create(Date.new(2018, 3, 15)),
      dimensions_edition: item,
    )
  end

  it 'only create a Metrics Fact entry for Content Items with latest = `true`' do
    create(:edition, latest: true, content_id: 'cid1')
    create(:edition, latest: false, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end
end
