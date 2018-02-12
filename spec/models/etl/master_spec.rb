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
end
