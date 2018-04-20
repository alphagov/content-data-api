require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe Feedex::Processor do
  subject { described_class }

  let!(:item1) { create :dimensions_item, base_path: '/path1' }
  let!(:item2) { create :dimensions_item, base_path: '/path2' }

  let(:date) { Date.new(2018, 2, 20) }
  let(:dimensions_date) { Dimensions::Date.for(date) }

  before { allow_any_instance_of(Feedex::Service).to receive(:find_in_batches).and_yield(feedex_response) }

  context 'When the base_path matches the feedex path' do
    it 'update the facts with the feedex metrics' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date
      fact2 = create :metric, dimensions_item: item2, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(fact1.reload).to have_attributes(feedex_comments: 21)
      expect(fact2.reload).to have_attributes(feedex_comments: 11)
    end

    it 'does not update metrics for other days' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date, feedex_comments: 1
      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(feedex_comments: 1)
    end

    it 'does not update metrics for other items' do
      item = create :dimensions_item, base_path: '/non-matching-path', latest: true
      fact = create :metric, dimensions_item: item, dimensions_date: dimensions_date, feedex_comments: 9

      described_class.process(date: date)

      expect(fact.reload).to have_attributes(feedex_comments: 9)
    end

    it 'deletes the events that matches the base_path of an item' do
      item2.destroy
      create :metric, dimensions_item: item1, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(Events::Feedex.count).to eq(1)
    end
  end

  context 'when there are events from other days' do
    before do
      create(:feedex, date: date - 1, page_path: '/path1')
      create(:feedex, date: date - 2, page_path: '/path1')
    end

    it 'only updates metrics for the current day' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(fact1.reload).to have_attributes(feedex_comments: 21)
    end

    it 'only deletes the events for the current day that matches' do
      create :metric, dimensions_item: item1, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(Events::Feedex.count).to eq(3)
    end
  end

private

  def feedex_response
    [
      {
        'date' => '2018-02-20',
        'page_path' => '/path1',
        'feedex_comments' => '21'
      },
      {
        'date' => '2018-02-20',
        'page_path' => '/path2',
        'feedex_comments' => '11'
      },
    ]
  end
end
