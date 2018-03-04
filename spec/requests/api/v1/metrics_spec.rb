require 'rails_helper'
RSpec.describe '/api/v1/metrics/:content_id', type: :request do
  before { create(:user) }

  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:day4) { create :dimensions_date, date: Date.new(2018, 1, 16) }

  let!(:item) { create :dimensions_item, content_id: 'id1' }

  let!(:metric1) { create :metric, dimensions_item: item, dimensions_date: day1 }
  let!(:metric2) { create :metric, dimensions_item: item, dimensions_date: day2 }
  let!(:metric3) { create :metric, dimensions_item: item, dimensions_date: day3 }
  let!(:metric4) { create :metric, dimensions_item: item, dimensions_date: day4 }

  it 'returns `bad request` for metrics not on the whitelist' do
    get '/api/v1/metrics/id1', params: { metric: 'something-else', from: '2018-01-13', to: '2018-01-15' }

    expect(response.status).to eq(400)
  end

  describe 'pageviews' do
    before do
      metric1.update pageviews: 10
      metric2.update pageviews: 20
      metric3.update pageviews: 30
      metric4.update pageviews: 40
    end

    it 'returns metric values between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'pageviews', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(api_reponse)
    end

    def api_reponse
      {
        metadata: {
          metric: 'pageviews',
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

  describe 'feedex issues' do
    before do
      metric1.update number_of_issues: 10
      metric2.update number_of_issues: 20
      metric3.update number_of_issues: 30
      metric4.update number_of_issues: 40
    end

    it 'returns metric values between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'number_of_issues', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(api_reponse)
    end

    def api_reponse
      {
        metadata: {
          metric: 'number_of_issues',
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

  describe 'number_of_pdfs' do
    before do
      old_version = create :dimensions_item, content_id: 'id1', number_of_pdfs: 30, latest: false
      metric1.update dimensions_item: old_version

      item.update number_of_pdfs: 20
    end

    it 'returns metric values between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'number_of_pdfs', from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(api_reponse)
    end

    def api_reponse
      {
        metadata: {
          metric: 'number_of_pdfs',
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

  describe 'number_of_word_files' do
    before do
      old_version = create :dimensions_item, content_id: 'id1', number_of_word_files: 30, latest: false
      metric1.update dimensions_item: old_version

      item.update number_of_word_files: 20
    end

    it 'returns metric values between two dates' do
      get '/api/v1/metrics/id1', params: { metric: 'number_of_word_files', from: '2018-01-13', to: '2018-01-15' }


      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(api_reponse)
    end

    def api_reponse
      {
        metadata: {
          metric: 'number_of_word_files',
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
