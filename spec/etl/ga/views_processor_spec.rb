require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe GA::ViewsProcessor do
  subject { described_class }

  let!(:item1) { create :dimensions_item, base_path: '/path1', latest: true }
  let!(:item2) { create :dimensions_item, base_path: '/path2', latest: true }

  let(:date) { Date.new(2018, 2, 20) }
  let(:dimensions_date) { Dimensions::Date.for(date) }


  context 'When the base_path matches the GA path' do
    before { allow(GA::ViewsService).to receive(:find_in_batches).and_yield(ga_response) }

    it 'update the facts with the GA metrics' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date
      fact2 = create :metric, dimensions_item: item2, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(fact1.reload).to have_attributes(pageviews: 1, unique_pageviews: 1)
      expect(fact2.reload).to have_attributes(pageviews: 2, unique_pageviews: 2)
    end

    it 'does not update metrics for other days' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date, pageviews: 20, unique_pageviews: 10

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(pageviews: 20, unique_pageviews: 10)
    end

    it 'does not update metrics for other items' do
      item = create :dimensions_item, base_path: '/non-matching-path', latest: true
      fact = create :metric, dimensions_item: item, dimensions_date: dimensions_date, pageviews: 99, unique_pageviews: 90

      described_class.process(date: date)

      expect(fact.reload).to have_attributes(pageviews: 99, unique_pageviews: 90)
    end

    it 'deletes the events that matches the base_path of an item' do
      item2.destroy
      create :metric, dimensions_item: item1, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(Events::GA.count).to eq(1)
    end

    it 'does not delete the events it does not have user views data' do
      create :ga_event, :with_user_feedback, date: date, page_path: item1.base_path
      create :metric, dimensions_item: item1, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(Events::GA.count).to eq(2)
    end

    context 'when there are events from other days' do
      before do
        create(:ga_event, :with_views, date: date - 1, page_path: '/path1')
        create(:ga_event, :with_views, date: date - 2, page_path: '/path1')
      end

      it 'only updates metrics for the current day' do
        fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date

        described_class.process(date: date)

        expect(fact1.reload).to have_attributes(pageviews: 1, unique_pageviews: 1)
      end

      it 'only deletes the events for the current day that matches the basepath of the item' do
        create :metric, dimensions_item: item1, dimensions_date: dimensions_date

        described_class.process(date: date)

        expect(Events::GA.count).to eq(3)
      end
    end
  end

  context 'when page_path starts "/https://www.gov.uk"' do
    before do
      allow(GA::ViewsService).to receive(:find_in_batches).and_yield(ga_response_with_govuk_prefix)
    end

    include_examples "transform path examples"
  end

  private

  def ga_response
    [
      {
        'page_path' => '/path1',
        'pageviews' => 1,
        'unique_pageviews' => 1,
        'date' => '2018-02-20',
        'process_name' => 'views',
      },
      {
        'page_path' => '/path2',
        'pageviews' => 2,
        'unique_pageviews' => 2,
        'date' => '2018-02-20',
        'process_name' => 'views',
      },
    ]
  end

  def ga_response_with_govuk_prefix
    [
      {
        'page_path' => '/https://www.gov.uk/path1',
        'pageviews' => 1,
        'unique_pageviews' => 1,
        'date' => '2018-02-20',
        'process_name' => 'views',
      },
      {
        'page_path' => '/path2',
        'pageviews' => 2,
        'unique_pageviews' => 2,
        'date' => '2018-02-20',
        'process_name' => 'views',
      },
    ]
  end
end
