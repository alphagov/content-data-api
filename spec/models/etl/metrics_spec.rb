require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Metrics do
  subject { described_class }

  let!(:date) { Dimensions::Date.build(Date.today) }

  let(:organisation) { create(:dimensions_organisation, content_id: 'id1') }

  it 'creates a Metrics fact per content item' do
    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    allow(ETL::Items).to receive(:process).and_return([
      create(:dimensions_item, organisation_id: 'id1'),
      create(:dimensions_item, organisation_id: 'id1'),
    ])

    subject.process

    expect(Facts::Metric.count).to eq(2)
  end

  it 'does not duplicate facts' do
    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    allow(ETL::Items).to receive(:process).and_return([
      create(:dimensions_item, organisation_id: 'id1'),
      create(:dimensions_item, organisation_id: 'id1'),
    ])

    2.times { subject.process }

    expect(Facts::Metric.count).to eq(2)
  end

  it 'does not raise an exception if the content item has no organisation' do
    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    allow(ETL::Items).to receive(:process).and_return([create(:dimensions_item, nil)])

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end

  it 'creates a metrics fact with the associated dimensions' do
    item = create(:dimensions_item, organisation_id: 'id1')

    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    allow(ETL::Items).to receive(:process).and_return([item])

    subject.process

    expect(Facts::Metric.first).to have_attributes(
      dimensions_date: date,
      dimensions_organisation: organisation,
      dimensions_item: item,
    )
  end

  it 'creates multiple items for multiple organisations' do
    organisation2 = create(:dimensions_organisation, content_id: 'id2')
    item1 = create(:dimensions_item, organisation_id: 'id1')
    item2 = create(:dimensions_item, organisation_id: 'id2')

    allow(ETL::Organisations).to receive(:process).and_return([organisation, organisation2])
    allow(ETL::Items).to receive(:process).and_return([item1, item2])

    subject.process

    expect(Facts::Metric.count).to eq(2)
    expect(Facts::Metric.first).to have_attributes(dimensions_item: item1, dimensions_organisation: organisation, dimensions_date: date)
    expect(Facts::Metric.second).to have_attributes(dimensions_item: item2, dimensions_organisation: organisation2, dimensions_date: date)
  end
end
