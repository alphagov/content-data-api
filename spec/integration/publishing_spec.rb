require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe 'Number of publishing items per organisation' do
  it 'return the number of publishing items for an organisation' do
    org1 = create(:dimensions_organisation, content_id: 'id1')
    org2 = create(:dimensions_organisation, content_id: 'id2')

    item1 = create(:dimensions_item, organisation_id: 'id1')
    item2 = create(:dimensions_item, organisation_id: 'id1')
    item3 = create(:dimensions_item, organisation_id: 'id2')

    date = Dimensions::Date.build(Date.today)

    Facts::Metric.create(dimensions_organisation: org1, dimensions_item: item1, dimensions_date: date)
    Facts::Metric.create(dimensions_organisation: org1, dimensions_item: item2, dimensions_date: date)
    Facts::Metric.create(dimensions_organisation: org2, dimensions_item: item3, dimensions_date: date)

    total_metrics = Facts::Metric.
      joins(:dimensions_organisation, :dimensions_item, :dimensions_date).
      where('dimensions_organisations.content_id = ?', 'id1').
      count

    expect(total_metrics).to eq(2)
  end
end
