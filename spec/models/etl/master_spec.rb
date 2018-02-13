require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Master do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  around do |example|
    Timecop.freeze(date) { example.run }
  end
  

  it 'creates a Metrics fact per content item' do
    create :dimensions_item, latest: true
    item = create(:dimensions_item, latest: true, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.find_by(dimensions_item: item)).to have_attributes(
      dimensions_date: Dimensions::Date.for(Date.new(2018,2,19)),
      dimensions_item: item,
    )
  end

  it 'only create a Metrics Fact entry for Content Items with latest = `true`' do
    create(:dimensions_item, latest: true, content_id: 'cid1')
    create(:dimensions_item, latest: false, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end
end
