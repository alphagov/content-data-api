RSpec.describe '/api/v1/content' do
  include ItemSetupHelpers
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
        item: { title: 'the title' },)
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
      create_metric(base_path: '/another/path', date: '2018-01-02',
        daily: {
          unique_pageviews: 34,
          is_this_useful_yes: 22,
          is_this_useful_no: 10,
          number_of_internal_searches: 15
        },
        item: {
          title: 'another org title',
          document_type: 'news_story',
          primary_organisation_content_id: another_org_id,
        })
      get "//api/v1/content", params: { from: '2018-01-01', to: '2018-09-01', organisation: primary_org_id }
    end

    it 'is successful' do
      expect(response.status).to eq(200)
    end

    it 'returns the correct data' do
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to match_array(
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

  context 'when no is_this_useful.. reponses' do
    before do
      create_metric(base_path: '/path/1', date: '2018-01-01',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 0,
          is_this_useful_no: 0,
        },

        item: { title: 'the title', primary_organisation_content_id: primary_org_id },)
      get "//api/v1/content", params: { from: '2018-01-01', to: '2018-09-01', organisation: primary_org_id }
    end

    it 'returns the nil for the satisfaction_score' do
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results][0]).to include(
        satisfaction_score: nil,
        satisfaction_score_responses: 0
      )
    end
  end
end
