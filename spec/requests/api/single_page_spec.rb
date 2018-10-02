require 'securerandom'

RSpec.describe '/single_page', type: :request do
  let!(:expected_time_series_metrics) { %w[unique_pageviews pageviews feedex_comments number_of_internal_searches satisfaction_score] }
  let!(:expected_edition_metrics) { %w[word_count number_of_pdfs] }

  let!(:base_path) { '/base_path' }
  let!(:item) do
    create :dimensions_item,
      latest: true,
      title: 'the title',
      base_path: base_path,
      document_type: 'guide',
      publishing_app: 'whitehall',
      first_published_at: '2018-07-17T10:35:59.000Z',
      public_updated_at: '2018-07-17T10:35:57.000Z',
      primary_organisation_title: 'The ministry'
  end

  before do
    create :user
    day1 = create :dimensions_date, date: Date.new(2018, 1, 0o1)
    day2 = create :dimensions_date, date: Date.new(2018, 1, 0o2)
    create :metric, dimensions_item: item, dimensions_date: day1, pageviews: 10, unique_pageviews: 10
    create :metric, dimensions_item: item, dimensions_date: day2, pageviews: 20, unique_pageviews: 20
    create :facts_edition, dimensions_item: item, dimensions_date: day1, word_count: 30, number_of_pdfs: 10
  end

  context 'when correct parameters supplied' do
    it 'returns the metadata' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01', to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected = {
        'metadata' => {
          "title" => 'the title',
          "base_path" => base_path,
          "document_type" => 'guide',
          "publishing_app" => 'whitehall',
          "first_published_at" => "2018-07-17T10:35:59.000Z",
          "public_updated_at" => '2018-07-17T10:35:57.000Z',
          "primary_organisation_title" => 'The ministry'
        }
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it 'returns the time period' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01', to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected = {
        'time_period' => {
          'from' => '2018-01-01',
          'to' => '2018-01-31'
        }
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it 'returns expected time series metrics' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01', to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected_metrics = expected_time_series_metrics.map { |metric_name|
        a_hash_including("name" => metric_name)
      }
      expected = {
        'time_series_metrics' => a_collection_including(*expected_metrics)
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it 'returns expected edition metrics' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01', to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected_metrics = expected_edition_metrics.map { |metric_name|
        a_hash_including("name" => metric_name)
      }
      expected = {
        'edition_metrics' => a_collection_including(*expected_metrics)
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it 'returns the value of an edition metrics' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01', to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected = {
        'edition_metrics' => a_collection_including(
          a_hash_including(
            "value" => 30,
            "name" => 'word_count'
          )
        )
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it 'returns the time series values for a time series metric' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01', to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected = {
        'time_series_metrics' => a_collection_including(
          a_hash_including(
            'name' => 'unique_pageviews',
            'time_series' => a_collection_including(
              { 'date' => '2018-01-01', 'value' => 10 },
              'date' => '2018-01-02', 'value' => 20
            )
          )
        )
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with to param missing' do
    it 'returns an error' do
      get "/single_page/#{base_path}", params: { from: '2018-01-01' }

      body = JSON.parse(response.body)

      expected = {
        'title' => 'One or more parameters is invalid',
        'invalid_params' => {
          'to' => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD"
          ]
        },
        'type' => 'https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error'
      }
      expect(body).to eq(expected)
      expect(response).to have_http_status(400)
    end
  end

  context 'with from param missing' do
    it 'returns an error' do
      get "/single_page/#{base_path}", params: { to: '2018-01-31' }

      body = JSON.parse(response.body)

      expected = {
        'title' => 'One or more parameters is invalid',
        'invalid_params' => {
          'from' => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD"
          ]
        },
        'type' => 'https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error'
      }
      expect(body).to eq(expected)
      expect(response).to have_http_status(400)
    end
  end

  context 'with from and to params missing' do
    it 'returns an error' do
      get "/single_page/#{base_path}"

      body = JSON.parse(response.body)

      expected = {
        'title' => 'One or more parameters is invalid',
        'invalid_params' => {
          'from' => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD"
          ],
          'to' => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD"
          ]
        },
        'type' => 'https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error'
      }
      expect(body).to eq(expected)
      expect(response).to have_http_status(400)
    end
  end
end
