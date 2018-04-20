require 'rails_helper'
require 'gds-api-adapters'

RSpec.describe GA::UserFeedbackProcessor do
  subject { described_class }

  let!(:item1) { create :dimensions_item, base_path: '/path1', latest: true }
  let!(:item2) { create :dimensions_item, base_path: '/path2', latest: true }

  let(:date) { Date.new(2018, 2, 20) }
  let(:dimensions_date) { Dimensions::Date.for(date) }


  context 'When the base_path matches the GA path' do
    before { allow_any_instance_of(GA::Service).to receive(:find_user_feedback_in_batches).and_yield(ga_response) }

    it 'update the facts with the GA metrics' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date
      fact2 = create :metric, dimensions_item: item2, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(fact1.reload).to have_attributes(is_this_useful_no: 1, is_this_useful_yes: 1)
      expect(fact2.reload).to have_attributes(is_this_useful_no: 5, is_this_useful_yes: 10)
    end

    it 'does not update metrics for other days' do
      fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date, is_this_useful_no: 20, is_this_useful_yes: 10

      day_before = date - 1
      described_class.process(date: day_before)

      expect(fact1.reload).to have_attributes(is_this_useful_no: 20, is_this_useful_yes: 10)
    end

    it 'does not update metrics for other items' do
      item = create :dimensions_item, base_path: '/non-matching-path', latest: true
      fact = create :metric, dimensions_item: item, dimensions_date: dimensions_date, is_this_useful_no: 99, is_this_useful_yes: 90

      described_class.process(date: date)

      expect(fact.reload).to have_attributes(is_this_useful_no: 99, is_this_useful_yes: 90)
    end

    it 'deletes the events that matches the base_path of an item' do
      item2.destroy
      create :metric, dimensions_item: item1, dimensions_date: dimensions_date

      described_class.process(date: date)

      expect(Events::GA.count).to eq(1)
    end

    context 'when there are events from other days' do
      before do
        create(:ga, date: date - 1, page_path: '/path1')
        create(:ga, date: date - 2, page_path: '/path1')
      end

      it 'only updates metrics for the current day' do
        fact1 = create :metric, dimensions_item: item1, dimensions_date: dimensions_date

        described_class.process(date: date)

        expect(fact1.reload).to have_attributes(is_this_useful_no: 1, is_this_useful_yes: 1)
      end

      it 'only deletes the events for the current day that matches' do
        create :metric, dimensions_item: item1, dimensions_date: dimensions_date

        described_class.process(date: date)

        expect(Events::GA.count).to eq(3)
      end
    end
  end

  context 'when page_path starts "/https://www.gov.uk"' do
    it 'removes the "/https://www.gov.uk" from the GA::Event page_path' do
      allow_any_instance_of(GA::Service).to receive(:find_in_batches).and_yield(ga_response_with_govuk_prefix)

      described_class.process(date: date)
      expect(Events::GA.where(page_path: '/https://gov.uk/path1').count).to eq 0
      expect(Events::GA.where(page_path: '/path1').count).to eq 1
    end
  end

private

  def ga_response
    [
      {
        'page_path' => '/path1',
        'is_this_useful_no' => 1,
        'is_this_useful_yes' => 1,
        'date' => '2018-02-20',
      },
      {
        'page_path' => '/path2',
        'is_this_useful_no' => 5,
        'is_this_useful_yes' => 10,
        'date' => '2018-02-20',
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
      },
      {
        'page_path' => '/path2',
        'pageviews' => 2,
        'unique_pageviews' => 2,
        'date' => '2018-02-20',
      },
    ]
  end
end
