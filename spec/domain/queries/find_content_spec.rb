RSpec.describe Queries::FindContent do
  include AggregationsSupport

  let(:primary_org_id) { '96cad973-92dc-41ea-a0ff-c377908fee74' }

  let(:filter) do
    {
      date_range: 'past-30-days',
      organisation_id: primary_org_id,
      document_type: nil
    }
  end

  before do
    create :user
  end

  it 'returns the aggregations for the past 30 days' do
    edition1 = create :edition, base_path: '/path1', date: 2.months.ago, organisation_id: primary_org_id
    edition2 = create :edition, base_path: '/path2', date: 2.months.ago, organisation_id: primary_org_id

    create :metric, edition: edition1, date: 15.days.ago, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10
    create :metric, edition: edition1, date: 10.days.ago, upviews: 20, useful_yes: 5, useful_no: 1, searches: 1
    create :metric, edition: edition2, date: 10.days.ago, upviews: 15, useful_yes: 8, useful_no: 19, searches: 10
    create :metric, edition: edition2, date: 11.days.ago, upviews: 10, useful_yes: 5, useful_no: 1, searches: 11

    recalculate_aggregations!

    response = described_class.call(filter: filter)
    expect(response[:results]).to contain_exactly(
      hash_including(upviews: 35, searches: 11, satisfaction: 0.5652173913043478, satisfaction_score_responses: 23),
      hash_including(upviews: 25, searches: 21, satisfaction: 0.3939393939393939, satisfaction_score_responses: 33),
    )
  end

  it 'returns the metadata for the past 30 days' do
    edition1 = create :edition,
      base_path: '/path1',
      organisation_id: primary_org_id,
      title: 'title-01',
      document_type: 'document-type-01'

    edition2 = create :edition,
      base_path: '/path2',
      organisation_id: primary_org_id,
      title: 'title-02',
      document_type: 'document-type-02'

    create :metric, edition: edition1, date: 15.days.ago
    create :metric, edition: edition2, date: 10.days.ago

    recalculate_aggregations!

    response = described_class.call(filter: filter)
    expect(response[:results]).to contain_exactly(
      hash_including(base_path: '/path1'),
      hash_including(base_path: '/path2'),
    )
  end

  describe 'Other date ranges' do
    let(:this_month_date) { Date.today }
    let(:edition1) { create :edition, base_path: '/path1', date: 2.months.ago, organisation_id: primary_org_id }
    let(:edition2) { create :edition, base_path: '/path2', date: 2.months.ago, organisation_id: primary_org_id }

    it 'returns aggregations for last month' do
      last_month_date = (Date.today - 1.month)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 8, useful_no: 9, searches: 10
      create :metric, edition: edition1, date: last_month_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 8, useful_no: 19, searches: 10
      create :metric, edition: edition2, date: last_month_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      filter = {
        date_range: 'last-month',
        organisation_id: primary_org_id,
        document_type: nil
      }

      recalculate_aggregations!

      response = described_class.call(filter: filter)

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 20, searches: 1, satisfaction: 0.8, satisfaction_score_responses: 5),
        hash_including(upviews: 10, searches: 11, satisfaction: 0.8, satisfaction_score_responses: 5),
      )
    end

    it 'returns aggregations for past 3 months' do
      two_months_ago_date = (Date.today - 2.month)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: two_months_ago_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition2, date: two_months_ago_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      filter = {
        date_range: 'past-3-months',
        organisation_id: primary_org_id,
        document_type: nil
      }

      recalculate_aggregations!

      response = described_class.call(filter: filter)

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 35, searches: 11, satisfaction: 0.5, satisfaction_score_responses: 10),
        hash_including(upviews: 25, searches: 21, satisfaction: 0.5, satisfaction_score_responses: 10),
      )
    end

    it 'returns aggregations for past 6 months' do
      five_months_ago_date = (Date.today - 5.month)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: five_months_ago_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition2, date: five_months_ago_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      filter = {
        date_range: 'past-6-months',
        organisation_id: primary_org_id,
        document_type: nil
      }

      recalculate_aggregations!

      response = described_class.call(filter: filter)

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 35, searches: 11, satisfaction: 0.5, satisfaction_score_responses: 10),
        hash_including(upviews: 25, searches: 21, satisfaction: 0.5, satisfaction_score_responses: 10),
      )
    end

    it 'returns aggregations for past year' do
      eleven_months_ago_date = (Date.today - 11.month)
      create :metric, edition: edition1, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition1, date: eleven_months_ago_date, upviews: 20, useful_yes: 4, useful_no: 1, searches: 1
      create :metric, edition: edition2, date: this_month_date, upviews: 15, useful_yes: 1, useful_no: 4, searches: 10
      create :metric, edition: edition2, date: eleven_months_ago_date, upviews: 10, useful_yes: 4, useful_no: 1, searches: 11

      filter = {
        date_range: 'past-year',
        organisation_id: primary_org_id,
        document_type: nil
      }

      recalculate_aggregations!

      response = described_class.call(filter: filter)

      expect(response[:results]).to contain_exactly(
        hash_including(upviews: 35, searches: 11, satisfaction: 0.5, satisfaction_score_responses: 10),
        hash_including(upviews: 25, searches: 21, satisfaction: 0.5, satisfaction_score_responses: 10),
      )
    end
  end

  describe 'Filter by all organisations' do
    let(:filter) do
      {
        date_range: 'past-30-days',
        organisation_id: 'all',
        document_type: nil
      }
    end

    let(:edition1) { create :edition, date: 15.days.ago }
    let(:edition2) { create :edition, date: 15.days.ago, organisation_id: nil }

    before do
      create :metric, edition: edition1, upviews: 20, date: 15.days.ago
      create :metric, edition: edition2, upviews: 10, date: 15.days.ago
      recalculate_aggregations!
    end

    it 'returns content from all organisations' do
      response = described_class.call(filter: filter)
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: edition1.base_path),
        hash_including(base_path: edition2.base_path)
      )
    end
  end

  describe 'Filter by null organisations' do
    let(:filter) do
      {
        date_range: 'past-30-days',
        organisation_id: 'none',
        document_type: nil
      }
    end

    let(:edition1) { create :edition, date: 15.days.ago, organisation_id: nil }

    before do
      create :metric, edition: edition1, date: 15.days.ago
      edition2 = create :edition, date: 15.days.ago, organisation_id: primary_org_id
      create :metric, edition: edition2, date: 15.days.ago
      recalculate_aggregations!
    end

    it 'returns content from editions which have no organisation' do
      response = described_class.call(filter: filter)
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: edition1.base_path)
      )
    end
  end

  describe 'Pagination' do
    before do
      4.times do |n|
        edition = create :edition,
          base_path: "/path/#{n}",
          organisation_id: primary_org_id,
          warehouse_item_id: "item-#{n}"
        create :metric, edition: edition, date: 15.days.ago, upviews: (100 - n)
      end

      # not latest edition - should not affect total results
      old_edition = create :edition,
        base_path: '/path/0',
        organisation_id: primary_org_id,
        latest: false,
        warehouse_item_id: 'item-0'
      create :metric, edition: old_edition, date: 15.days.ago


      recalculate_aggregations!
    end

    it 'returns the first page of data with pagination info' do
      response = described_class.call(filter: filter.merge(page: 1, page_size: 2))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: '/path/0'),
        hash_including(base_path: '/path/1'),
      )
      expect(response).to include(
        page: 1,
        total_pages: 2,
        total_results: 4,
      )
    end

    it 'returns the second page of data' do
      response = described_class.call(filter: filter.merge(page: 2, page_size: 2))
      expect(response[:results]).to contain_exactly(
        hash_including(base_path: '/path/2'),
        hash_including(base_path: '/path/3'),
      )
      expect(response).to include(
        page: 2,
        total_pages: 2,
        total_results: 4,
      )
    end
  end

  describe 'Order' do
    it 'defaults order by unique pageviews' do
      edition1 = create :edition, title: 'last', organisation_id: primary_org_id
      edition2 = create :edition, title: 'middle', organisation_id: primary_org_id
      edition3 = create :edition, title: 'first', organisation_id: primary_org_id

      create :metric, edition: edition1, date: 15.days.ago, upviews: 1
      create :metric, edition: edition2, date: 15.days.ago, upviews: 2
      create :metric, edition: edition3, date: 15.days.ago, upviews: 3
      recalculate_aggregations!

      response = described_class.call(filter: filter)

      titles = response.fetch(:results).map { |result| result.fetch(:title) }
      expect(titles).to eq(%w(first middle last))
    end
  end

  describe 'when no useful_yes/no.. responses' do
    before do
      edition = create :edition, organisation_id: primary_org_id
      create :metric, edition: edition, date: 15.days.ago, useful_yes: 0, useful_no: 0

      recalculate_aggregations!
    end

    it 'returns the nil for the satisfaction' do
      results = described_class.call(filter: filter)
      expect(results[:results].first).to include(
        satisfaction: nil,
        satisfaction_score_responses: 0
      )
    end
  end

  describe 'when no metrics in the date range' do
    before do
      create :edition, date: '2018-02-01'

      recalculate_aggregations!
    end

    it 'returns a empty array' do
      results = described_class.call(filter: filter)
      expect(results[:results]).to be_empty
    end
  end

  describe 'when invalid filter' do
    it 'raises an error if no `organisation_id` attribute' do
      filter.delete :organisation_id

      expect(-> { described_class.call(filter: filter) }).to raise_error(ArgumentError)
    end

    it 'raises an error if no `date_range` attribute' do
      filter.delete :date_range

      expect(-> { described_class.call(filter: filter) }).to raise_error(ArgumentError)
    end
  end

  describe 'Filter by title / url' do
    it 'returns the editions matching a title' do
      edition1 = create :edition, title: 'this is a big title', date: 2.months.ago, organisation_id: primary_org_id
      edition2 = create :edition, title: 'this is a small title', date: 2.months.ago, organisation_id: primary_org_id

      create :metric, edition: edition1, date: 15.days.ago
      create :metric, edition: edition2, date: 14.days.ago
      recalculate_aggregations!

      result = described_class.call(filter: filter.merge(search_term: 'big title'))
      expect(result[:results]).to contain_exactly(
        hash_including(title: 'this is a big title'),
      )
    end

    it 'returns the editions matching a base_path' do
      edition1 = create :edition, base_path: '/this/is/a/big/base-path', date: 2.months.ago, organisation_id: primary_org_id
      edition2 = create :edition, base_path: '/this/is/a/small/base-path', date: 2.months.ago, organisation_id: primary_org_id

      create :metric, edition: edition1, date: 15.days.ago
      create :metric, edition: edition2, date: 14.days.ago
      recalculate_aggregations!

      result = described_class.call(filter: filter.merge(search_term: 'big base-path'))
      expect(result[:results]).to contain_exactly(
        hash_including(base_path: '/this/is/a/big/base-path'),
      )
    end
  end
end
