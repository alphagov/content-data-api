require 'rails_helper'

RSpec.describe Facts::Metric, type: :model do
  it { is_expected.to validate_presence_of(:dimensions_date) }
  it { is_expected.to validate_presence_of(:dimensions_item) }

  let(:day0) { create(:dimensions_date, date: Date.new(2018, 1, 12)) }
  let(:day1) { create(:dimensions_date, date: Date.new(2018, 1, 13)) }
  let(:day2) { create(:dimensions_date, date: Date.new(2018, 1, 14)) }
  describe 'Filtering' do
    subject { described_class }

    it '.between' do
      item1 = create(:dimensions_item)

      create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)

      results = subject.between(day1, day2)
      expect(results).to match_array([metric2, metric3])
    end

    it '.by_base_path' do
      item1 = create(:dimensions_item, base_path: '/path1')
      item2 = create(:dimensions_item, base_path: '/path2')

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
      create(:metric, dimensions_item: item2, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      results = subject.by_base_path('/path1')
      expect(results).to match_array([metric1, metric2, metric3])
    end

    it '.by_content_id' do
      item1 = create(:dimensions_item, content_id: 'id1')
      item2 = create(:dimensions_item, content_id: 'id2')

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      metric3 = create(:metric, dimensions_item: item1, dimensions_date: day2)
      create(:metric, dimensions_item: item2, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      results = subject.by_content_id('id1')
      expect(results).to match_array([metric1, metric2, metric3])
    end

    it '.by_organisation_id' do
      item1 = create(:dimensions_item, primary_organisation_content_id: 'org-1')
      item2 = create(:dimensions_item, primary_organisation_content_id: 'org-2')

      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      metric2 = create(:metric, dimensions_item: item1, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)
      create(:metric, dimensions_item: item2, dimensions_date: day1)
      create(:metric, dimensions_item: item2, dimensions_date: day2)

      results = subject.by_organisation_id('org-1')
      expect(results).to match_array([metric1, metric2])
    end

    it '.by_locale' do
      item1 = create(:dimensions_item, locale: 'fr')
      item2 = create(:dimensions_item, locale: 'de')
      metric1 = create(:metric, dimensions_item: item1, dimensions_date: day0)
      create(:metric, dimensions_item: item2, dimensions_date: day0)
      results = subject.by_locale('fr')
      expect(results).to match_array(metric1)
    end
  end

  describe '.metric_summary' do
    subject { described_class }

    let(:base_path) { '/the/base/path' }

    it 'returns the correct numbers' do
      item1 = create(:dimensions_item, latest: false, base_path: base_path, number_of_pdfs: 3, number_of_word_files: 1, spell_count: 3, readability_score: 4)
      item2 = create(:dimensions_item, base_path: base_path, number_of_pdfs: 3, number_of_word_files: 1, spell_count: 3, readability_score: 4)

      create(:metric, dimensions_item: item1, dimensions_date: day0, pageviews: 3, unique_pageviews: 2,
                      feedex_comments: 4, is_this_useful_yes: 1, is_this_useful_no: 1, number_of_internal_searches: 9)
      create(:metric, dimensions_item: item2, dimensions_date: day0, pageviews: 5, unique_pageviews: 2,
                      feedex_comments: 3, is_this_useful_yes: 2, is_this_useful_no: 2, number_of_internal_searches: 9)
      create(:metric, dimensions_item: item2, dimensions_date: day1, pageviews: 2, unique_pageviews: 2,
                      feedex_comments: 2, is_this_useful_yes: 3, is_this_useful_no: 3, number_of_internal_searches: 9)

      results = subject.between(day0, day1).by_base_path(base_path).metric_summary

      expect(results).to eq(
        total_items: 2,
        pageviews: 10,
        unique_pageviews: 2,
        feedex_comments: 9,
        number_of_pdfs: 3,
        number_of_word_files: 1,
        spell_count: 3,
        readability_score: 4,
        is_this_useful_yes: 2,
        is_this_useful_no: 2,
        number_of_internal_searches: 9
      )
    end
  end
end
