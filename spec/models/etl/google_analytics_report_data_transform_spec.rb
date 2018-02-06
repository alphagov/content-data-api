require 'rails_helper'

RSpec.describe ETL::GoogleAnalyticsReportDataTransform do
  subject(:transform) do
    described_class.new(
      date_dimension: date_dimension,
      item_dimension_scope: item_dimension_scope
    )
  end

  let(:date_dimension) { create(:dimensions_date) }
  let(:item_dimension) { create(:dimensions_item) }
  let(:item_dimension_scope) { class_double('Dimensions::Item') }

  describe '#process' do
    subject do
      transform.process(
        'ga:pagePath' => page_path,
        'ga:pageviews' => pageviews,
        'ga:uniquePageviews' => unique_pageviews
      )
    end

    let(:page_path) { double }
    let(:pageviews) { double }
    let(:unique_pageviews) { double }

    context 'when an item dimension exists matching the ga:pagePath' do
      before do
        expect(item_dimension_scope)
          .to receive_message_chain('where.pluck.first') { item_dimension.id }
      end

      it 'transforms the report row into values that can be imported' do
        is_expected.to include(dimensions_date_id: date_dimension.id,
                               dimensions_item_id: item_dimension.id,
                               pageviews: pageviews,
                               unique_pageviews: unique_pageviews)
      end
    end

    context 'when no item dimension exists matching the ga:pagePath' do
      let(:item_dimension) { nil }

      before do
        expect(item_dimension_scope)
          .to receive_message_chain('where.pluck.first') { nil }
      end

      it 'should discard the report row' do
        is_expected.to be_nil
      end
    end
  end
end
