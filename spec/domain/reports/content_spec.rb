RSpec.describe Reports::Content do
  include ItemSetupHelpers

  let(:primary_org_id) { '96cad973-92dc-41ea-a0ff-c377908fee74' }
  let(:warehouse_item_id) { '87d87ac6-e5b5-4065-a8b5-b7a43db648d2' }
  let(:another_warehouse_item_id) { 'ebf0dd2f-9d99-48e3-84d0-e94a2108ef45' }

  before do
    create :user
  end

  context 'when successful' do
    before do
      create_metric(base_path: '/path/1', date: '2018-01-01',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 50,
          is_this_useful_no: 20,
          number_of_internal_searches: 20,
        },
        item: {
          title: 'the title',
          document_type: 'news_story',
          primary_organisation_content_id: primary_org_id,
          latest: false,
          warehouse_item_id: warehouse_item_id,
        })

      create_metric(base_path: '/path/1', date: '2018-01-02',
        daily: {
          unique_pageviews: 133,
          is_this_useful_yes: 150,
          is_this_useful_no: 30,
          number_of_internal_searches: 200
        },
        item: {
          title: 'the title',
          document_type: 'news_story',
          primary_organisation_content_id: primary_org_id,
          latest: true,
          warehouse_item_id: warehouse_item_id,
        })

      create_metric(base_path: '/path/2', date: '2018-01-02',
        daily: {
          unique_pageviews: 20,
          is_this_useful_yes: 10,
          is_this_useful_no: 10,
          number_of_internal_searches: 7
        },
        item: {
          title: 'title 2',
          document_type: 'press_release',
          primary_organisation_content_id: primary_org_id,
          latest: true,
          warehouse_item_id: another_warehouse_item_id,
        })
    end

    it 'returns the correct data' do
      results = described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)
      expect(results).to eq(
        [
          {
            base_path: '/path/1',
            title: 'the title',
            unique_pageviews: 233,
            document_type: 'news_story',
            satisfaction_score: 0.8,
            satisfaction_score_responses: 250,
            number_of_internal_searches: 220
          },
          {
            base_path: '/path/2',
            title: 'title 2',
            unique_pageviews: 20,
            document_type: 'press_release',
            satisfaction_score: 0.5,
            satisfaction_score_responses: 20,
            number_of_internal_searches: 7
          }
        ]
      )
    end
  end


  context 'the attributes we are displaying have changed over time' do
    before do
      create_metric(base_path: '/old/base/path', date: '2018-01-01',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 10,
          is_this_useful_no: 10,
          number_of_internal_searches: 15,
        },
        item: {
          title: 'old title',
          document_type: 'news_story',
          primary_organisation_content_id: primary_org_id,
          latest: false,
          warehouse_item_id: warehouse_item_id,
        })
      create_metric(base_path: '/new/base/path', date: '2018-01-01',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 50,
          is_this_useful_no: 50,
          number_of_internal_searches: 5,
        },
        item: {
          title: 'new title',
          document_type: 'press_release',
          primary_organisation_content_id: primary_org_id,
          latest: true,
          warehouse_item_id: warehouse_item_id,
        })
    end

    it 'returns metrics from all versions with metadata from the latest version' do
      results = described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)
      expect(results.count).to eq(1)
      expect(results.first).to eq(
        base_path: '/new/base/path',
        title: 'new title',
        unique_pageviews: 200,
        document_type: 'press_release',
        satisfaction_score: 0.5,
        satisfaction_score_responses: 120,
        number_of_internal_searches: 20
      )
    end
  end

  context 'when no is_this_useful.. responses' do
    before do
      create_metric(base_path: '/path/1', date: '2018-01-01',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 0,
          is_this_useful_no: 0,
        },
        item: {
          title: 'the title',
          primary_organisation_content_id: primary_org_id,
          warehouse_item_id: warehouse_item_id,
        })
    end

    it 'returns the nil for the satisfaction_score' do
      results = described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)
      expect(results.first).to include(
        satisfaction_score: nil,
        satisfaction_score_responses: 0
      )
    end
  end

  context 'when no metrics in the date range' do
    before do
      create_metric(base_path: '/path/1', date: '2018-01-01',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 0,
          is_this_useful_no: 0,
        },
        item: { title: 'the title',
          primary_organisation_content_id: primary_org_id,
          warehouse_item_id: warehouse_item_id, })
    end

    it 'returns a empty array' do
      results = described_class.retrieve(from: '2018-02-01', to: '2018-02-02', organisation_id: primary_org_id)
      expect(results).to be_empty
    end
  end

  context 'when no items exist for the organisation' do
    it 'returns a empty array' do
      results = described_class.retrieve(from: '2018-02-01', to: '2018-02-02', organisation_id: primary_org_id)
      expect(results).to be_empty
    end
  end
end
