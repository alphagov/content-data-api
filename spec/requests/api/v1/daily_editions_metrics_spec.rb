require 'securerandom'

RSpec.describe '/api/v1/metrics/', type: :request do
  include ItemSetupHelpers
  before { create(:user) }

  let!(:base_path) { '/base_path' }
  let(:warehouse_item_id) { '35058ac0-fb70-4220-81dc-c8b14bededdc' }

  before do
    create_metric(base_path: base_path, date: '2018-01-13',
      edition: {
        number_of_pdfs: 30, number_of_word_files: 30, readability_score: 123
      },
      item: { latest: false, warehouse_item_id: warehouse_item_id })
    create_metric(base_path: base_path, date: '2018-01-14',
      edition: {
        number_of_pdfs: 20, number_of_word_files: 20, readability_score: 5
      },
      item: { latest: true, warehouse_item_id: warehouse_item_id })
    create_metric base_path: base_path, date: '2018-01-15', item: { warehouse_item_id: warehouse_item_id, latest: true }
    create_metric base_path: base_path, date: '2018-01-16', item: { warehouse_item_id: warehouse_item_id, latest: true }
  end

  it 'returns the `number of pdfs` between two dates' do
    get "/api/v1/metrics/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[number_of_pdfs] }
    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_pdfs'))
  end

  it 'returns the `number of word documents` between two dates' do
    get "/api/v1/metrics/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[number_of_word_files] }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(api_reponse('number_of_word_files'))
  end

  it 'returns the `readability score` between two dates' do
    get "/api/v1/metrics/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15', metrics: %w[readability_score] }

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
