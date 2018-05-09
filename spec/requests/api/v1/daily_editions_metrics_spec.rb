require 'rails_helper'
require 'securerandom'

RSpec.describe '/api/v1/metrics/', type: :request do
  before { create(:user) }

  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:day4) { create :dimensions_date, date: Date.new(2018, 1, 16) }
  let!(:content_id) { SecureRandom.uuid }
  let!(:base_path) { '/base_path' }

  before do
    item_day1 = create :dimensions_item, base_path: base_path, locale: 'en', latest: false
    item_day2 = create :dimensions_item, base_path: base_path, locale: 'en', latest: true

    create :facts_edition, dimensions_item: item_day1, dimensions_date: day1, number_of_pdfs: 30, number_of_word_files: 30, readability_score: 123
    create :facts_edition, dimensions_item: item_day2, dimensions_date: day2, number_of_pdfs: 20, number_of_word_files: 20, readability_score: 5

    create :dimensions_item, content_id: content_id, locale: 'en'

    create :metric, dimensions_item: item_day1, dimensions_date: day1
    create :metric, dimensions_item: item_day2, dimensions_date: day2
    create :metric, dimensions_item: item_day2, dimensions_date: day3
    create :metric, dimensions_item: item_day2, dimensions_date: day4
  end

  it 'returns the `number of pdfs` between two dates' do
    get "/api/v1/metrics/number_of_pdfs/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_pdfs'))
  end

  it 'returns the `number of word documents` between two dates' do
    get "/api/v1/metrics/number_of_word_files/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_word_files'))
  end

  it 'returns the `readability score` between two dates' do
    get "/api/v1/metrics/readability_score/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(
      readability_score: [
        { date: '2018-01-13', value: 123 },
        { date: '2018-01-14', value: 5 },
        { date: '2018-01-15', value: 5 },
      ]
    )
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
