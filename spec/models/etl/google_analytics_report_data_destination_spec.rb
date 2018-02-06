require 'rails_helper'

RSpec.describe ETL::GoogleAnalyticsReportDataDestination do
  subject(:destination) { described_class.new }

  let(:date_dimension) { create(:dimensions_date) }
  let(:item_dimensions) { create_list(:dimensions_item, 2) }

  context 'writing new facts to the metric fact table' do
    subject do
      destination.write(dimensions_date_id: date_dimension.id,
                        dimensions_item_id: item_dimensions.first.id,
                        pageviews: 10,
                        unique_pageviews: 5)

      destination.write(dimensions_date_id: date_dimension.id,
                        dimensions_item_id: item_dimensions.second.id,
                        pageviews: 20,
                        unique_pageviews: 5)
    end

    it 'imports the values into the metric fact table' do
      expect { subject }.to change { Facts::Metric.count }.from(0).to(2)
    end
  end

  context 'updating existing facts in the metric fact table' do
    let!(:existing_fact) do
      create(:facts_metric,
             dimensions_date: date_dimension,
             dimensions_item: item_dimensions.first,
             pageviews: 1,
             unique_pageviews: 1)
    end

    subject do
      destination.write(dimensions_date_id: date_dimension.id,
                        dimensions_item_id: item_dimensions.first.id,
                        pageviews: 50,
                        unique_pageviews: 20)

      destination.write(dimensions_date_id: date_dimension.id,
                        dimensions_item_id: item_dimensions.second.id,
                        pageviews: 9,
                        unique_pageviews: 3)
    end

    it 'imports the values into the metric fact table' do
      expect { subject }
        .to change { Facts::Metric.count }.from(1).to(2)

      expect(existing_fact.reload)
        .to have_attributes(pageviews: 50, unique_pageviews: 20)
    end
  end
end
