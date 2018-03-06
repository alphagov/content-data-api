require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Master do
  subject { described_class }

  let(:date) { Date.new(2018, 2, 20) }

  around do |example|
    Timecop.freeze(date) { example.run }
  end

  before { allow(ETL::GA).to receive(:process) }
  before { allow(ETL::Feedex).to receive(:process) }
  before { allow(ETL::OutdatedItems).to receive(:process) }

  it 'creates a Metrics fact per content item' do
    create :dimensions_item, latest: true
    item = create(:dimensions_item, latest: true, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.find_by(dimensions_item: item)).to have_attributes(
      dimensions_date: Dimensions::Date.for(Date.new(2018, 2, 19)),
      dimensions_item: item,
    )
  end

  it 'only create a Metrics Fact entry for Content Items with latest = `true`' do
    create(:dimensions_item, latest: true, content_id: 'cid1')
    create(:dimensions_item, latest: false, content_id: 'cid1')

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end

  it 'updates the dirty items' do
    subject.process

    expect(ETL::OutdatedItems).to have_received(:process)
  end

  it 'update GA metrics in the Facts table' do
    expect(ETL::GA).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'update Feedex metrics in the Facts table' do
    expect(ETL::Feedex).to receive(:process).with(date: Date.new(2018, 2, 19))

    subject.process
  end

  it 'can run the process for other days' do
    expect(ETL::GA).to receive(:process).with(date: Date.new(2018, 2, 25))
    item = create(:dimensions_item, latest: true, content_id: 'cid1')

    subject.process(date: Date.new(2018, 2, 25))

    expect(Facts::Metric.find_by(dimensions_item: item)).to have_attributes(
      dimensions_date: Dimensions::Date.for(Date.new(2018, 2, 25)),
      dimensions_item: item,
    )
  end
end
