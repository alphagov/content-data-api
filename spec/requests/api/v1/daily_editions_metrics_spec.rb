require 'rails_helper'
require 'securerandom'

RSpec.describe '/api/v1/metrics/', type: :request do
  before { create(:user) }

  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:day4) { create :dimensions_date, date: Date.new(2018, 1, 16) }
  let!(:content_id) { SecureRandom.uuid }

  let!(:item) { create :dimensions_item, content_id: content_id, locale: 'en' }
  let!(:item_non_english) { create :dimensions_item, content_id: content_id, locale: 'de' }

  before do
    item1_old = create :dimensions_item,
      content_id: content_id, locale: 'en', number_of_pdfs: 30, number_of_word_files: 30, readability_score: 123, latest: false
    item.update number_of_pdfs: 20, number_of_word_files: 20, readability_score: 5
    item_non_english.update number_of_pdfs: 200, number_of_word_files: 100

    create :metric, dimensions_item: item1_old, dimensions_date: day1
    create :metric, dimensions_item: item_non_english, dimensions_date: day2, pageviews: 10, feedex_comments: 10
    create :metric, dimensions_item: item, dimensions_date: day2
    create :metric, dimensions_item: item, dimensions_date: day3
    create :metric, dimensions_item: item, dimensions_date: day4
  end

  it 'returns the `number of pdfs` between two dates' do
    get "/api/v1/metrics/number_of_pdfs/#{content_id}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_pdfs'))
  end

  it 'returns the `number of word documents` between two dates' do
    get "/api/v1/metrics/number_of_word_files/#{content_id}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_word_files'))
  end

  it 'returns the `readability score` between two dates' do
    get "/api/v1/metrics/readability_score/#{content_id}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq({
      readability_score: [
        { date: '2018-01-13', value: 123 },
        { date: '2018-01-14', value: 5 },
        { date: '2018-01-15', value: 5 },
      ]
    })
  end

  def api_reponse(metric_name)
    {
      metric_name.to_sym => [
        { date: '2018-01-13', value: 30 },
        { date: '2018-01-14', value: 20 },
        { date: '2018-01-15', value: 20 },
      ]
    }
  end
end
