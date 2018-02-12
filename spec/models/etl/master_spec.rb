require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Master do
  subject { described_class }

  let!(:date) { Dimensions::Date.build(Date.today) }

  it 'creates a Metrics fact per content item' do
    expect(ETL::Items).to receive(:process) do
      create :dimensions_item, latest: true
      create :dimensions_item, latest: true
    end
    subject.process

    expect(Facts::Metric.count).to eq(2)
  end

  it 'does not duplicate facts' do
    expect(ETL::Items).to receive(:process).twice do
      Dimensions::Item.update(latest: false)
      create :dimensions_item, latest: true
      create :dimensions_item, latest: true
    end

    2.times { subject.process }

    expect(Facts::Metric.count).to eq(2)
  end

  it 'does not raise an exception if the content item has no organisation' do
    expect(ETL::Items).to receive(:process) do
      create :dimensions_item, latest: true
    end

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end

  it 'creates a metrics fact with the associated dimensions' do
    expect(ETL::Items).to receive(:process) do
      create(:dimensions_item, latest: true, content_id: 'cid1')
    end

    subject.process

    expect(Facts::Metric.first).to have_attributes(
      dimensions_date: date,
      dimensions_item: Dimensions::Item.find_by(content_id: 'cid1'),
    )
  end

  it 'creates multiple items for multiple organisations' do
    expect(ETL::Items).to receive(:process) do
      create(:dimensions_item, latest: true, content_id: 'cid1')
      create(:dimensions_item, latest: true, content_id: 'cid2')
    end
    subject.process

    expect(Facts::Metric.count).to eq(2)
    item1 = Dimensions::Item.find_by(content_id: 'cid1')
    item2 = Dimensions::Item.find_by(content_id: 'cid2')
    expect(Facts::Metric.first).to have_attributes(dimensions_item: item1, dimensions_date: date)
    expect(Facts::Metric.second).to have_attributes(dimensions_item: item2, dimensions_date: date)
  end
end
