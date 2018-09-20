RSpec.describe Reports::Content do
  include ItemSetupHelpers

  let(:primary_org_id) { '96cad973-92dc-41ea-a0ff-c377908fee74' }

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
        })
    end

    it 'returns the correct data' do
      expect(described_class.retrieve(from: '2018-01-01', to: '2018-02-01', organisation_id: primary_org_id)).to match_array(
        [
          base_path: '/path/1',
          title: 'the title',
          unique_pageviews: 233,
          document_type: 'news_story',
          satisfaction_score: 0.8,
          satisfaction_score_responses: 250,
          number_of_internal_searches: 220
        ]
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
        item: { title: 'the title', primary_organisation_content_id: primary_org_id })
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
        item: { title: 'the title', primary_organisation_content_id: primary_org_id })
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
