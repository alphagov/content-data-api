require 'rails_helper'
RSpec.describe '/api/v1/metrics/:content_id', type: :request do
  before { create(:user) }

  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:day4) { create :dimensions_date, date: Date.new(2018, 1, 16) }

  let!(:item) { create :dimensions_item, content_id: 'id1' }

  it 'returns `bad request` for metrics not on the whitelist' do
    get '/api/v1/metrics/id1', params: { metric: 'something-else', from: '2018-01-13', to: '2018-01-15' }

    expect(response.status).to eq(400)
  end

  describe 'Daily metrics' do
    before do
      create :metric, dimensions_item: item, dimensions_date: day1, pageviews: 10, number_of_issues: 10
      create :metric, dimensions_item: item, dimensions_date: day2, pageviews: 20, number_of_issues: 20
      create :metric, dimensions_item: item, dimensions_date: day3, pageviews: 30, number_of_issues: 30
      create :metric, dimensions_item: item, dimensions_date: day4, pageviews: 40, number_of_issues: 40
    end

    it 'returns `pageviews` values between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'pageviews', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json).to eq(build_api_response('pageviews'))
    end

    it 'returns `feedex issues` between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'number_of_issues', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(build_api_response('number_of_issues'))
    end

    def build_api_response(metric_name)
      {
        metadata: {
          metric: metric_name,
          total: 60,
          from: '2018-01-13',
          to: '2018-01-15',
          content_id: 'id1',
        },
        results: [
          { content_id: 'id1', date: '2018-01-13', value: 10 },
          { content_id: 'id1', date: '2018-01-14', value: 20 },
          { content_id: 'id1', date: '2018-01-15', value: 30 },
        ]
      }
    end
  end

  describe 'Content metrics' do
    before do
      item1_old = create :dimensions_item, content_id: 'id1', number_of_pdfs: 30, number_of_word_files: 30, latest: false
      item.update number_of_pdfs: 20, number_of_word_files: 20

      create :metric, dimensions_item: item1_old, dimensions_date: day1
      create :metric, dimensions_item: item, dimensions_date: day2
      create :metric, dimensions_item: item, dimensions_date: day3
      create :metric, dimensions_item: item, dimensions_date: day4
    end

    it 'returns the `number of pdfs` between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'number_of_pdfs', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_pdfs'))
    end

    it 'returns the `number of word documents` between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'number_of_word_files', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_word_files'))
    end

    def api_reponse(metric_name)
      {
        metadata: {
          metric: metric_name,
          total: 70,
          from: '2018-01-13',
          to: '2018-01-15',
          content_id: 'id1',
        },
        results: [
          { content_id: 'id1', date: '2018-01-13', value: 30 },
          { content_id: 'id1', date: '2018-01-14', value: 20 },
          { content_id: 'id1', date: '2018-01-15', value: 20 },
        ]
      }
    end
  end
end
