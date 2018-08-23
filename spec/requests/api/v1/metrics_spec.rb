require 'securerandom'

RSpec.describe '/api/v1/metrics/', type: :request do
  before { create(:user) }

  let!(:day1) { create :dimensions_date, date: Date.new(2018, 1, 13) }
  let!(:day2) { create :dimensions_date, date: Date.new(2018, 1, 14) }
  let!(:day3) { create :dimensions_date, date: Date.new(2018, 1, 15) }
  let!(:day4) { create :dimensions_date, date: Date.new(2018, 1, 16) }
  let!(:content_id) { SecureRandom.uuid }
  let!(:base_path) { '/base_path' }

  let!(:item) { create :dimensions_item, content_id: content_id, base_path: base_path, locale: 'en' }
  let!(:item_fr) { create :dimensions_item, content_id: content_id, locale: 'de' }

  describe "an API response" do
    it "should be cacheable until the end of the day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 0, 0, 0)) do
        get "/api/v1/metrics/"

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=3600, public"
      end
    end

    it "expires at 1am" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        get "/api/v1/metrics/"

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=0, public"
      end
    end

    it "can be cached for up to a day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 1)) do
        get "/api/v1/metrics/"

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=86399, public"
      end
    end
  end

  describe "invalid requests" do
    it 'returns an error for metrics not on the whitelist' do
      get "/api/v1/metrics/number_of_puns/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors/#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "metric" => ["is not included in the list"] }
      }

      expect(json).to eq(expected_error_response)
    end

    it 'returns an error for badly formatted dates' do
      get "/api/v1/metrics/pageviews/#{base_path}/time-series", params: { from: 'today', to: '2018-01-15' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors/#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "from" => ["Dates should use the format YYYY-MM-DD"] }
      }

      expect(json).to eq(expected_error_response)
    end

    it 'returns an error for bad date ranges' do
      get "/api/v1/metrics/pageviews/#{base_path}/time-series", params: { from: '2018-01-16', to: '2018-01-15' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors/#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "from,to" => ["`from` parameter can't be after the `to` parameter"] }
      }

      expect(json).to eq(expected_error_response)
    end

    it 'returns an error for unknown parameters' do
      get "/api/v1/metrics/pageviews/#{base_path}/time-series", params: { from: '2018-01-14', to: '2018-01-15', extra: "bla" }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors/#unknown-parameter",
        "title" => "One or more parameter names are invalid",
        "invalid_params" => ["extra"]
      }

      expect(json).to eq(expected_error_response)
    end
  end

  describe 'Daily metrics' do
    before do
      create :metric, dimensions_item: item, dimensions_date: day1, pageviews: 10, feedex_comments: 10, is_this_useful_yes: 10, is_this_useful_no: 20
      create :metric, dimensions_item: item_fr, dimensions_date: day2, pageviews: 100, feedex_comments: 200, is_this_useful_yes: 10, is_this_useful_no: 20
      create :metric, dimensions_item: item, dimensions_date: day2, pageviews: 20, feedex_comments: 20, is_this_useful_yes: 10, is_this_useful_no: 20
      create :metric, dimensions_item: item, dimensions_date: day3, pageviews: 30, feedex_comments: 30, is_this_useful_yes: 10, is_this_useful_no: 20
      create :metric, dimensions_item: item, dimensions_date: day4, pageviews: 40, feedex_comments: 40, is_this_useful_yes: 10, is_this_useful_no: 20
      create :facts_edition, dimensions_item: item, dimensions_date: day1
    end

    it 'returns `pageviews` values between two dates' do
      get "/api/v1/metrics/pageviews/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json).to eq(build_time_series_response('pageviews'))
    end

    it 'returns `satisfaction_score` values between two dates' do
      get "/api/v1/metrics/satisfaction_score/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }
      satisfaction_score = {
        satisfaction_score: [
          {
              date: "2018-01-13",
              value: 0.333333333333333
          },
          {
              date: "2018-01-14",
              value: 0.333333333333333
          },
          {
              date: "2018-01-15",
              value: 0.333333333333333
          }
        ]
      }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json).to eq(satisfaction_score)
    end

    it 'returns `feedex issues` between two dates' do
      get "/api/v1/metrics/feedex_comments/#{base_path}/time-series", params: { from: '2018-01-13', to: '2018-01-15' }

      json = JSON.parse(response.body)
      expect(json.deep_symbolize_keys).to eq(build_time_series_response('feedex_comments'))
    end

    describe "Summary information" do
      it 'returns sums and latest values' do
        get "//api/v1/metrics/feedex_comments/#{base_path}", params: { from: '2018-01-13', to: '2018-01-15' }

        json = JSON.parse(response.body)

        expected_response = {
          feedex_comments: {
            total: 60,
            latest: 30
          }
        }
        expect(json.deep_symbolize_keys).to eq(expected_response)
      end
    end

    def build_time_series_response(metric_name)
      {
        metric_name.to_sym => [
          { date: '2018-01-13', value: 10 },
          { date: '2018-01-14', value: 20 },
          { date: '2018-01-15', value: 30 },
        ]
      }
    end
  end

  describe "metrics index" do
    it "describes the available metrics" do
      get "/api/v1/metrics"

      json = JSON.parse(response.body)

      expect(json.count).to eq(::Metric.find_all.length)

      expect(json).to include("name" => "pageviews",
        "description" => "Number of pageviews",
        "source" => "Google Analytics")
    end
  end
end
