RSpec.describe '/content' do
  include ItemSetupHelpers
  before do
    create :user
  end

  let(:primary_org_id) { SecureRandom.uuid }
  let(:another_org_id) { SecureRandom.uuid }
  let(:warehouse_item_id) { '87d87ac6-e5b5-4065-a8b5-b7a43db648d2' }
  let(:another_warehouse_item_id) { 'ebf0dd2f-9d99-48e3-84d0-e94a2108ef45' }

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
          title: 'old title',
          document_type: 'news_story',
          primary_organisation_content_id: primary_org_id,
          latest: false,
          warehouse_item_id: warehouse_item_id,
        })

      create_metric(base_path: '/new/base/path', date: '2018-01-02',
        daily: {
          unique_pageviews: 133,
          is_this_useful_yes: 150,
          is_this_useful_no: 30,
          number_of_internal_searches: 200
        },
        item: {
          title: 'latest title',
          document_type: 'latest_doc_type',
          primary_organisation_content_id: primary_org_id,
          latest: true,
          warehouse_item_id: warehouse_item_id,
        })
      create_metric(base_path: '/path/2', date: '2018-01-02',
        daily: {
          unique_pageviews: 100,
          is_this_useful_yes: 10,
          is_this_useful_no: 10,
          number_of_internal_searches: 1
        },
        item: {
          title: 'another title',
          document_type: 'organisation',
          primary_organisation_content_id: primary_org_id,
          warehouse_item_id: another_warehouse_item_id,
        })
      create_metric(base_path: '/another/org/path', date: '2018-01-02',
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
      get "/content", params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id }
    end

    it 'is successful' do
      expect(response.status).to eq(200)
    end

    it 'returns the data summarized with metadata from latest item' do
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to eq(
        [
          {
            base_path: '/new/base/path',
            title: 'latest title',
            unique_pageviews: 233,
            document_type: 'latest_doc_type',
            satisfaction_score: 0.8,
            satisfaction_score_responses: 250,
            number_of_internal_searches: 220
          },
          {
            base_path: '/path/2',
            title: 'another title',
            unique_pageviews: 100,
            document_type: 'organisation',
            satisfaction_score: 0.5,
            satisfaction_score_responses: 20,
            number_of_internal_searches: 1
          }
        ]
      )
    end
  end

  describe "an API response" do
    it "should be cacheable until the end of the day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 0, 0, 0)) do
        get "/content", params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id }

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=3600, public"
      end
    end

    it "expires at 1am" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 0)) do
        get "/content", params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id }

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=0, public"
      end
    end

    it "can be cached for up to a day" do
      Timecop.freeze(Time.zone.local(2020, 1, 1, 1, 0, 1)) do
        get "/content", params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id }

        expect(response.headers['ETag']).to be_present
        expect(response.headers['Cache-Control']).to eq "max-age=86399, public"
      end
    end
  end


  context 'with invalid params' do
    it 'returns an error for badly formatted dates' do
      get "/content", params: { from: 'today', to: '2018-01-15', organisation_id: '386ea723-d8fc-4581-8e53-bb8ee9aa8c03' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "from" => ["Dates should use the format YYYY-MM-DD"] }
      }

      expect(json).to eq(expected_error_response)
    end

    it 'returns an error for bad date ranges' do
      get "/content/", params: { from: '2018-01-16', to: '2018-01-15', organisation_id: '1182a3ed-a9a3-482c-81e1-0a9ecfb847d0' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "from,to" => ["`from` parameter can't be after the `to` parameter"] }
      }

      expect(json).to eq(expected_error_response)
    end

    it 'returns an error for invalid organisation_id' do
      get "/content/", params: { from: '2018-01-16', to: '2018-01-17', organisation_id: 'blah' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "organisation_id" => ["this is not a valid organisation id"] }
      }

      expect(json).to eq(expected_error_response)
    end
  end
end
