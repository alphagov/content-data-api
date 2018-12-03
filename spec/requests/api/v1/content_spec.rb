RSpec.describe '/content' do
  include AggregationsSupport

  before { create :user }

  let(:organisation_id) { 'e12e3c54-b544-4d94-ba1f-9846144374d2' }

  describe 'Aggregations' do
    let(:edition1) { create :edition, date: 1.month.ago, organisation_id: organisation_id }
    let(:edition2) { create :edition, replaces: edition1, organisation_id: organisation_id, base_path: '/path-01' }
    let(:edition3) { create :edition, date: 3.months.ago, organisation_id: organisation_id, base_path: '/path-02' }
    let(:beginning_of_this_month) { Date.yesterday.beginning_of_month }
    let(:beginning_of_last_month) { Date.yesterday.beginning_of_month - 1.month }

    context 'last 30 days' do
      before do
        create :metric, date: 12.days.ago, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20
        create :metric, date: 15.days.ago, edition: edition3, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10
        create :metric, date: 30.days.ago, edition: edition2, upviews: 50, useful_yes: 5, useful_no: 5, searches: 2
        # should not include metrics below
        create :metric, date: 32.days.ago, edition: edition2, upviews: 20, useful_yes: 20, useful_no: 20, searches: 20
        create :metric, date: 45.days.ago, edition: edition3, upviews: 100, useful_yes: 100, useful_no: 100, searches: 100

        recalculate_aggregations!
      end

      it 'returns 200 status' do
        get '/content', params: { date_range: 'past-30-days', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        expect(response).to have_http_status(200)
      end

      it 'returns aggregated metrics' do
        get '/content', params: { date_range: 'past-30-days', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:results]).to contain_exactly(
          a_hash_including(
            base_path: '/path-01',
            upviews: 150,
            satisfaction: 0.6875,
            satisfaction_score_responses: 80,
            searches: 22
          ),
          a_hash_including(
            base_path: '/path-02',
            upviews: 10,
            satisfaction: 0.5,
            satisfaction_score_responses: 20,
            searches: 10
          )
        )
      end
    end

    context 'last month' do
      before do
        create :metric, date: beginning_of_last_month, edition: edition3, upviews: 100, useful_yes: 100, useful_no: 100, searches: 100
        # should not include metrics below
        create :metric, date: beginning_of_this_month, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20
        create :metric, date: beginning_of_this_month, edition: edition2, upviews: 50, useful_yes: 5, useful_no: 5, searches: 2
        create :metric, date: beginning_of_this_month, edition: edition3, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10

        recalculate_aggregations!
      end

      it 'returns 200 status' do
        get '/content', params: { date_range: 'last-month', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        expect(response).to have_http_status(200)
      end

      it 'returns aggregated metrics' do
        get '/content', params: { date_range: 'last-month', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:results]).to contain_exactly(
          a_hash_including(
            base_path: '/path-02',
            upviews: 100,
            satisfaction: 0.5,
            satisfaction_score_responses: 200,
            searches: 100
          )
        )
      end
    end

    context 'last 3 months' do
      before do
        create :metric, date: beginning_of_this_month, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20
        create :metric, date: beginning_of_this_month, edition: edition2, upviews: 50, useful_yes: 5, useful_no: 5, searches: 2
        create :metric, date: beginning_of_last_month, edition: edition3, upviews: 100, useful_yes: 100, useful_no: 100, searches: 100
        create :metric, date: 2.months.ago, edition: edition3, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10
        # should not include metrics below
        create :metric, date: 5.months.ago, edition: edition2, upviews: 20, useful_yes: 20, useful_no: 20, searches: 20

        recalculate_aggregations!
      end

      it 'returns 200 status' do
        get '/content', params: { date_range: 'past-3-months', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        expect(response).to have_http_status(200)
      end

      it 'returns aggregated metrics' do
        get '/content', params: { date_range: 'past-3-months', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        json = JSON.parse(response.body).deep_symbolize_keys

        expect(json[:results]).to contain_exactly(
          a_hash_including(
            base_path: '/path-01',
            upviews: 150,
            satisfaction: 0.6875,
            satisfaction_score_responses: 80,
            searches: 22
          ),
          a_hash_including(
            base_path: '/path-02',
            upviews: 110,
            satisfaction: 0.5,
            satisfaction_score_responses: 220,
            searches: 110
          )
        )
      end
    end

    context 'last 6 months' do
      before do
        create :metric, date: beginning_of_this_month, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20
        create :metric, date: beginning_of_this_month, edition: edition2, upviews: 50, useful_yes: 5, useful_no: 5, searches: 2
        create :metric, date: beginning_of_this_month, edition: edition3, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10
        create :metric, date: beginning_of_last_month, edition: edition3, upviews: 100, useful_yes: 100, useful_no: 100, searches: 100
        create :metric, date: 5.months.ago, edition: edition2, upviews: 20, useful_yes: 20, useful_no: 20, searches: 20
        # should not include metrics below
        create :metric, date: 11.months.ago, edition: edition3, upviews: 1000, useful_yes: 1000, useful_no: 1000, searches: 1000

        recalculate_aggregations!
      end

      it 'returns 200 status' do
        get '/content', params: { date_range: 'past-6-months', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        expect(response).to have_http_status(200)
      end

      it 'returns aggregated metrics' do
        get '/content', params: { date_range: 'past-6-months', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:results]).to contain_exactly(
          a_hash_including(
            base_path: '/path-01',
            upviews: 170,
            satisfaction: 0.625,
            satisfaction_score_responses: 120,
            searches: 42
          ),
          a_hash_including(
            base_path: '/path-02',
            upviews: 110,
            satisfaction: 0.5,
            satisfaction_score_responses: 220,
            searches: 110
          )
        )
      end
    end

    context 'last year' do
      before do
        create :metric, date: beginning_of_this_month, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20
        create :metric, date: beginning_of_this_month, edition: edition2, upviews: 50, useful_yes: 5, useful_no: 5, searches: 2
        create :metric, date: beginning_of_this_month, edition: edition3, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10
        create :metric, date: beginning_of_last_month, edition: edition3, upviews: 100, useful_yes: 100, useful_no: 100, searches: 100
        create :metric, date: 5.months.ago, edition: edition2, upviews: 20, useful_yes: 20, useful_no: 20, searches: 20
        create :metric, date: 11.months.ago, edition: edition3, upviews: 1000, useful_yes: 1000, useful_no: 1000, searches: 1000
        # should not include metrics below
        create :metric, date: 13.months.ago, edition: edition3, upviews: 1000, useful_yes: 1000, useful_no: 1000, searches: 1000

        recalculate_aggregations!
      end

      it 'returns 200 status' do
        get '/content', params: { date_range: 'past-year', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        expect(response).to have_http_status(200)
      end

      it 'returns aggregated metrics' do
        get '/content', params: { date_range: 'past-year', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2' }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:results]).to contain_exactly(
          a_hash_including(
            base_path: '/path-01',
            upviews: 170,
            satisfaction: 0.625,
            satisfaction_score_responses: 120,
            searches: 42
          ),
          a_hash_including(
            base_path: '/path-02',
            upviews: 1110,
            satisfaction: 0.5,
            satisfaction_score_responses: 2220,
            searches: 1110
          )
        )
      end
    end
  end

  describe 'Filter by document type' do
    before do
      edition1 = create :edition, date: 1.month.ago, document_type: 'a-document-type', organisation_id: organisation_id
      create :metric, date: 15.days.ago, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20

      edition2 = create :edition, date: 1.month.ago, organisation_id: organisation_id
      create :metric, date: 10.days.ago, edition: edition2, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10

      recalculate_aggregations!
    end

    subject { get '/content', params: { date_range: 'past-30-days', document_type: 'a-document-type', organisation_id: organisation_id } }

    it 'returns 200 status' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'filters by document_type' do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
    end
  end

  describe 'Filter by title' do
    before do
      edition1 = create :edition, date: 1.month.ago, organisation_id: organisation_id, title: 'title1'
      edition2 = create :edition, date: 1.month.ago, organisation_id: organisation_id, title: 'title2'

      create :metric, date: 15.days.ago, edition: edition1
      create :metric, date: 10.days.ago, edition: edition2

      recalculate_aggregations!
    end

    subject { get '/content', params: { date_range: 'past-30-days', search_term: 'title1', organisation_id: organisation_id } }

    it 'returns 200 status' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'filters by title' do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
    end
  end

  describe 'Filter by base_path' do
    before do
      edition1 = create :edition, date: 1.month.ago, organisation_id: organisation_id, base_path: 'base_path1'
      edition2 = create :edition, date: 1.month.ago, organisation_id: organisation_id, base_path: 'base_path2'

      create :metric, date: 15.days.ago, edition: edition1
      create :metric, date: 10.days.ago, edition: edition2

      recalculate_aggregations!
    end

    subject { get '/content', params: { date_range: 'past-30-days', search_term: 'base_path1', organisation_id: organisation_id } }

    it 'returns 200 status' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'filters by base_path' do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
    end
  end

  describe 'Relevant content' do
    subject { get '/content', params: { date_range: 'past-30-days', organisation_id: organisation_id } }

    before do
      create_edition_and_metric('redirect')
      create_edition_and_metric('gone')
      create_edition_and_metric('news_story')
      recalculate_aggregations!
    end

    it 'filters out `gone` and `redirect`' do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
      expect(json[:results].first).to include(document_type: 'news_story')
    end
  end

  def create_edition_and_metric(document_type)
    edition = create :edition,
                     document_type: document_type,
                     date: 15.days.ago,
                     organisation_id: organisation_id
    create :metric, edition: edition, date: 15.days.ago
    edition
  end

  describe 'Pagination' do
    before do
      edition1 = create :edition, organisation_id: organisation_id, document_type: 'a-document-type', base_path: '/path-01'
      create :metric, date: 15.days.ago, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20

      edition2 = create :edition, organisation_id: organisation_id, base_path: '/path-02'
      create :metric, date: 10.days.ago, edition: edition2, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10

      recalculate_aggregations!
    end

    it 'returns the first page of the data' do
      get '/content', params: { date_range: 'past-30-days', organisation_id: organisation_id, page: 1, page_size: 1 }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to contain_exactly(a_hash_including(base_path: '/path-01'))
      expect(json).to include(page: 1, total_results: 2)
    end

    it 'returns the second page of the data' do
      get '/content', params: { date_range: 'past-30-days', organisation_id: organisation_id, page: 2, page_size: 1 }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to contain_exactly(a_hash_including(base_path: '/path-02'))
      expect(json).to include(page: 2, total_results: 2)
    end
  end

  include_examples 'API response', '/content', date_range: 'past-30-days', organisation_id: 'e12e3c54-b544-4d94-ba1f-9846144374d2'

  context 'with invalid params' do
    it 'returns an error for badly formatted dates' do
      get '/content', params: { date_range: 'invalid-range', organisation_id: '386ea723-d8fc-4581-8e53-bb8ee9aa8c03' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        'type' => 'https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error',
        'title' => 'One or more parameters is invalid',
        'invalid_params' => { 'date_range' => ['this is not a valid date range'] }
      }

      expect(json).to eq(expected_error_response)
    end

    it 'returns an error for invalid organisation_id' do
      get '/content/', params: { date_range: 'past-30-days', organisation_id: 'blah' }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        'type' => 'https://content-performance-api.publishing.service.gov.uk/errors.html#validation-error',
        'title' => 'One or more parameters is invalid',
        'invalid_params' => { 'organisation_id' => ['this is not a valid organisation id'] }
      }

      expect(json).to eq(expected_error_response)
    end
  end
end
