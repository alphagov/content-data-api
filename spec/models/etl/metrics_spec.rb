require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe ETL::Metrics do
  subject { described_class }

  let!(:date) { Dimensions::Date.build(Date.today) }

  let(:organisation) { create(:dimensions_organisation, content_id: 'id1') }

  let(:pageviews_response) do
    GoogleAnalyticsFactory
      .build_pageviews_response(
        [
          {
            base_path: "/link1",
            page_views: 20,
            unique_page_views: 10,
          },
        ]
      )
  end

  before do
    allow_any_instance_of(GoogleAnalytics::Client).to receive(:build) do
      double(batch_get_reports: pageviews_response)
    end
  end

  it 'creates a Metrics fact per content item' do
    expect(ETL::Items).to receive(:process) do
      create :dimensions_item, latest: true, organisation_id: 'id1'
      create :dimensions_item, latest: true, organisation_id: 'id1'
    end
    allow(ETL::Organisations).to receive(:process).and_return([organisation])

    subject.process

    expect(Facts::Metric.count).to eq(2)
  end

  it 'does not duplicate facts' do
    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    expect(ETL::Items).to receive(:process).twice do
      Dimensions::Item.update(latest: false)
      create :dimensions_item, latest: true, organisation_id: 'id1'
      create :dimensions_item, latest: true, organisation_id: 'id1'
    end

    2.times { subject.process }

    expect(Facts::Metric.count).to eq(2)
  end

  it 'does not raise an exception if the content item has no organisation' do
    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    expect(ETL::Items).to receive(:process) do
      create :dimensions_item, latest: true, organisation_id: nil
    end

    subject.process

    expect(Facts::Metric.count).to eq(1)
  end

  it 'creates a metrics fact with the associated dimensions' do
    allow(ETL::Organisations).to receive(:process).and_return([organisation])
    expect(ETL::Items).to receive(:process) do
      create(:dimensions_item, organisation_id: 'id1', latest: true, content_id: 'cid1', link: '/link1')
    end

    subject.process

    expect(Facts::Metric.first).to have_attributes(
      dimensions_date: date,
      dimensions_organisation: organisation,
      dimensions_item: Dimensions::Item.find_by(content_id: 'cid1'),
      pageviews: 20,
      unique_pageviews: 10,
    )
  end

  it 'creates multiple items for multiple organisations' do
    expect(ETL::Items).to receive(:process) do
      create(:dimensions_item, organisation_id: 'id1', latest: true, content_id: 'cid1')
      create(:dimensions_item, organisation_id: 'id2', latest: true, content_id: 'cid2')
    end

    organisation2 = create(:dimensions_organisation, content_id: 'id2')
    allow(ETL::Organisations).to receive(:process).and_return([organisation, organisation2])

    subject.process

    expect(Facts::Metric.count).to eq(2)
    item1 = Dimensions::Item.find_by(content_id: 'cid1')
    item2 = Dimensions::Item.find_by(content_id: 'cid2')
    expect(Facts::Metric.first).to have_attributes(dimensions_item: item1, dimensions_organisation: organisation, dimensions_date: date)
    expect(Facts::Metric.second).to have_attributes(dimensions_item: item2, dimensions_organisation: organisation2, dimensions_date: date)
  end
end
