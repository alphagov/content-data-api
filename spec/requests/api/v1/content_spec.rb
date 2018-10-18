RSpec.describe '/content' do
  before do
    create :user
  end

  let(:primary_org_id) { SecureRandom.uuid }
  let(:another_org_id) { SecureRandom.uuid }
  let(:warehouse_item_id) { '87d87ac6-e5b5-4065-a8b5-b7a43db648d2' }
  let(:another_warehouse_item_id) { 'ebf0dd2f-9d99-48e3-84d0-e94a2108ef45' }

  context 'when successful' do
    before do
      old_edition = create :edition,
        base_path: '/path/1',
        date: '2018-01-01',
        title: 'old-title',
        document_type: 'old_doc_type',
        organisation_id: primary_org_id
      create :metric,
        date: '2018-01-01',
        edition: old_edition,
        upviews: 100,
        useful_yes: 50,
        useful_no: 20,
        searches: 20
      new_edition = create :edition,
        replaces: old_edition,
        date: '2018-01-02',
        base_path: '/new/base/path',
        title: 'latest title',
        document_type: 'latest_doc_type',
        organisation_id: primary_org_id
      create :metric,
        edition: new_edition,
        date: '2018-01-02',
        upviews: 133,
        useful_yes: 150,
        useful_no: 30,
        searches: 200
      different_edition = create :edition,
        base_path: '/path/2',
        date: '2018-01-02',
        title: 'another title',
        document_type: 'organisation',
        organisation_id: primary_org_id,
        warehouse_item_id: another_warehouse_item_id
      create :metric,
        edition: different_edition,
        date: '2018-01-02',
        upviews: 100,
        useful_yes: 10,
        useful_no: 10,
        searches: 1
      another_org_edition = create :edition,
        base_path: '/another/org/path',
        date: '2018-01-02',
        title: 'another org title',
        document_type: 'news_story',
        organisation_id: another_org_id
      create :metric,
        edition: another_org_edition,
        upviews: 34
    end

    it 'returns aggregated metrics from all versions with metadata from the latest version' do
      get '/content', params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id }
      expect(response.status).to eq(200)
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to eq(
        [
          {
            base_path: '/new/base/path',
            title: 'latest title',
            upviews: 233,
            document_type: 'latest_doc_type',
            satisfaction: 0.8,
            satisfaction_score_responses: 250,
            searches: 220
          },
          {
            base_path: '/path/2',
            title: 'another title',
            upviews: 100,
            document_type: 'organisation',
            satisfaction: 0.5,
            satisfaction_score_responses: 20,
            searches: 1
          }
        ]
      )
    end

    it 'returns organisation id' do
      get '/content', params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id }
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:organisation_id]).to eq primary_org_id
    end

    it 'filters by document_type' do
      get '/content', params: { from: '2018-01-01', to: '2018-09-01', organisation_id: primary_org_id, document_type: 'latest_doc_type' }
      expect(response.status).to eq(200)
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
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
