require 'rails_helper'
require 'securerandom'

RSpec.describe '/api/v1/organisations/', type: :request do
  before { create(:user) }

  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:day4) { create :dimensions_date, date: Date.new(2018, 1, 16) }
  let!(:content_id1) { SecureRandom.uuid }
  let!(:content_id2) { SecureRandom.uuid }
  let!(:content_id3) { SecureRandom.uuid }
  let!(:organisation_id1) { SecureRandom.uuid }
  let!(:organisation_id2) { SecureRandom.uuid }

  let!(:item1) { create :dimensions_item, content_id: content_id1, primary_organisation_content_id: organisation_id1 }
  let!(:item2) { create :dimensions_item, content_id: content_id2, primary_organisation_content_id: organisation_id1 }
  let!(:item3) { create :dimensions_item, content_id: content_id3, primary_organisation_content_id: organisation_id2 }


  before do
    # For this organisation's content
    create :metric, dimensions_item: item1, dimensions_date: day1, pageviews: 10
    create :metric, dimensions_item: item1, dimensions_date: day2, pageviews: 20
    create :metric, dimensions_item: item1, dimensions_date: day3, pageviews: 30
    create :metric, dimensions_item: item1, dimensions_date: day4, pageviews: 40

    create :metric, dimensions_item: item2, dimensions_date: day1, pageviews: 100
    create :metric, dimensions_item: item2, dimensions_date: day2, pageviews: 200
    create :metric, dimensions_item: item2, dimensions_date: day3, pageviews: 300
    create :metric, dimensions_item: item2, dimensions_date: day4, pageviews: 400

    # For the other organisation's content
    create :metric, dimensions_item: item3, dimensions_date: day1, pageviews: 999
    create :metric, dimensions_item: item3, dimensions_date: day2, pageviews: 999
    create :metric, dimensions_item: item3, dimensions_date: day3, pageviews: 999
    create :metric, dimensions_item: item3, dimensions_date: day4, pageviews: 999
  end

  it 'returns an error for invalid organisation ids' do
    get "/api/v1/organisations/not-a-uuid/pageviews/", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)

    expect(response.status).to eq(400)

    expect(json.deep_symbolize_keys).to eq({
      invalid_params: {organisation_id: ["Organisation ID must be a UUID."]},
      title: "One or more parameters is invalid",
      type: "https://content-performance-api.publishing.service.gov.uk/errors/#validation-error"
    })
  end

  it 'summarises metrics over a content estate between two dates' do
    get "/api/v1/organisations/#{organisation_id1}/pageviews/", params: { from: '2018-01-13', to: '2018-01-15' }

    json = JSON.parse(response.body)
    expect(json.deep_symbolize_keys).to eq(summary_response(:pageviews, total: 660, latest: 330))
  end

  def empty_response(metric_name)
    {
      metric_name => []
    }
  end

  def summary_response(metric_name, total:, latest:)
    {
      metric_name => {
        total: total,
        latest: latest
      }
    }
  end
end
