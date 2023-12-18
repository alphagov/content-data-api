RSpec.describe "/content" do
  include AggregationsSupport

  before { create :user }

  let(:primary_organisation_id) { "e12e3c54-b544-4d94-ba1f-9846144374d2" }
  let(:two_days_ago) { Time.zone.today - 2 }

  describe "content item attributes" do
    it "contains the expected metrics" do
      edition1 = create :edition, date: 1.month.ago, primary_organisation_id:, base_path: "/path-01", facts: { pdf_count: 10, words: 300, reading_time: 2 }
      create :metric, date: 2.days.ago, edition: edition1, pviews: 1, upviews: 1, feedex: 1, useful_no: 1, useful_yes: 1, searches: 1
      recalculate_aggregations!

      get "/content", params: { date_range: "past-30-days", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to contain_exactly(
        a_hash_including(
          pviews: 1,
          upviews: 1,
          feedex: 1,
          useful_no: 1,
          useful_yes: 1,
          satisfaction: 0.5,
          searches: 1,
          pdf_count: 10,
          word_count: 300,
          reading_time: 2,
        ),
      )
    end

    it "contains the expected metadata" do
      edition1 = create :edition, date: 1.month.ago, title: "title", primary_organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2", document_type: "guide", base_path: "/path-01"
      create :metric, date: 2.days.ago, edition: edition1
      recalculate_aggregations!

      get "/content", params: { date_range: "past-30-days", organisation_id: "all" }
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to contain_exactly(
        a_hash_including(
          base_path: "/path-01",
          title: "title",
          organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2",
          document_type: "guide",
        ),
      )
    end
  end

  describe "time periods" do
    let(:edition1) { create :edition, date: 1.month.ago, primary_organisation_id:, base_path: "/path-01" }
    let(:edition2) { create :edition, date: 3.months.ago, primary_organisation_id:, base_path: "/path-02" }
    let(:beginning_of_this_month) { two_days_ago.beginning_of_month }
    let(:beginning_of_last_month) { two_days_ago.beginning_of_month - 1.month }

    context "last month" do
      before do
        create :metric, date: 1.month.ago.beginning_of_month, edition: edition1, pviews: 10
        create :metric, date: 2.months.ago, edition: edition1, pviews: 100
        create :metric, date: 5.months.ago, edition: edition1, pviews: 1000
        create :metric, date: 11.months.ago, edition: edition1, pviews: 10_000

        create :metric, date: 1.month.ago.beginning_of_month, edition: edition2, pviews: 20
        create :metric, date: 2.months.ago, edition: edition2, pviews: 200
        create :metric, date: 5.months.ago, edition: edition2, pviews: 2000
        create :metric, date: 11.months.ago, edition: edition2, pviews: 20_000

        recalculate_aggregations!
      end

      it "returns 200 status" do
        get "/content", params: { date_range: "last-month", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
        expect(response).to have_http_status(200)
      end

      it "returns aggregated metrics" do
        get "/content", params: { date_range: "last-month", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json[:results]).to contain_exactly(
          a_hash_including(base_path: "/path-01", pviews: 10),
          a_hash_including(base_path: "/path-02", pviews: 20),
        )
      end
    end

    context "other periods" do
      before do
        create :metric, date: 2.days.ago, edition: edition1, pviews: 1
        create :metric, date: 2.months.ago, edition: edition1, pviews: 10
        create :metric, date: 5.months.ago, edition: edition1, pviews: 100
        create :metric, date: 11.months.ago, edition: edition1, pviews: 1000

        create :metric, date: 2.days.ago, edition: edition2, pviews: 2
        create :metric, date: 2.months.ago, edition: edition2, pviews: 20
        create :metric, date: 5.months.ago, edition: edition2, pviews: 200
        create :metric, date: 11.months.ago, edition: edition2, pviews: 2000

        recalculate_aggregations!
      end

      context "past 30 days" do
        it "returns 200 status" do
          get "/content", params: { date_range: "past-30-days", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          expect(response).to have_http_status(200)
        end

        it "returns metrics in the correct time period" do
          get "/content", params: { date_range: "past-30-days", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          json = JSON.parse(response.body).deep_symbolize_keys
          expect(json[:results]).to contain_exactly(
            a_hash_including(base_path: "/path-01", pviews: 1),
            a_hash_including(base_path: "/path-02", pviews: 2),
          )
        end
      end

      context "past 3 months" do
        it "returns 200 status" do
          get "/content", params: { date_range: "past-3-months", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          expect(response).to have_http_status(200)
        end

        it "returns aggregated metrics" do
          get "/content", params: { date_range: "past-3-months", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          json = JSON.parse(response.body).deep_symbolize_keys

          expect(json[:results]).to contain_exactly(
            a_hash_including(base_path: "/path-01", pviews: 11),
            a_hash_including(base_path: "/path-02", pviews: 22),
          )
        end
      end

      context "past 6 months" do
        it "returns 200 status" do
          get "/content", params: { date_range: "past-6-months", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          expect(response).to have_http_status(200)
        end

        it "returns aggregated metrics" do
          get "/content", params: { date_range: "past-6-months", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          json = JSON.parse(response.body).deep_symbolize_keys
          expect(json[:results]).to contain_exactly(
            a_hash_including(base_path: "/path-01", pviews: 111),
            a_hash_including(base_path: "/path-02", pviews: 222),
          )
        end
      end

      context "past year" do
        it "returns 200 status" do
          get "/content", params: { date_range: "past-year", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          expect(response).to have_http_status(200)
        end

        it "returns aggregated metrics" do
          get "/content", params: { date_range: "past-year", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2" }
          json = JSON.parse(response.body).deep_symbolize_keys
          expect(json[:results]).to contain_exactly(
            a_hash_including(base_path: "/path-01", pviews: 1111),
            a_hash_including(base_path: "/path-02", pviews: 2222),
          )
        end
      end
    end
  end

  describe "Filter by document type" do
    before do
      edition1 = create(:edition, date: 1.month.ago, document_type: "a-document-type", primary_organisation_id:)
      create :metric, date: 15.days.ago, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20

      edition2 = create(:edition, date: 1.month.ago, primary_organisation_id:)
      create :metric, date: 10.days.ago, edition: edition2, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10

      recalculate_aggregations!
    end

    subject { get "/content", params: { date_range: "past-30-days", document_type: "a-document-type", organisation_id: primary_organisation_id } }

    it "returns 200 status" do
      subject

      expect(response).to have_http_status(200)
    end

    it "filters by document_type" do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
    end
  end

  describe "Filter by title" do
    before do
      edition1 = create :edition, date: 1.month.ago, primary_organisation_id:, title: "title1"
      edition2 = create :edition, date: 1.month.ago, primary_organisation_id:, title: "title2"

      create :metric, date: 15.days.ago, edition: edition1
      create :metric, date: 10.days.ago, edition: edition2

      recalculate_aggregations!
    end

    subject { get "/content", params: { date_range: "past-30-days", search_term: "title1", organisation_id: primary_organisation_id } }

    it "returns 200 status" do
      subject

      expect(response).to have_http_status(200)
    end

    it "filters by title" do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
    end
  end

  describe "Filter by base_path" do
    before do
      edition1 = create :edition, date: 1.month.ago, primary_organisation_id:, base_path: "base_path1"
      edition2 = create :edition, date: 1.month.ago, primary_organisation_id:, base_path: "base_path2"

      create :metric, date: 15.days.ago, edition: edition1
      create :metric, date: 10.days.ago, edition: edition2

      recalculate_aggregations!
    end

    subject { get "/content", params: { date_range: "past-30-days", search_term: "base_path1", organisation_id: primary_organisation_id } }

    it "returns 200 status" do
      subject

      expect(response).to have_http_status(200)
    end

    it "filters by base_path" do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
    end
  end

  describe "Filter by all organisations" do
    let(:another_org_id) { "c97bbc95-967a-4678-848b-6f393171f194" }
    let(:edition1) { create :edition, primary_organisation_id:, date: 15.days.ago }
    let(:edition2) { create :edition, primary_organisation_id: another_org_id, date: 15.days.ago }

    subject { get "/content", params: { date_range: "past-30-days", organisation_id: "all" } }

    before do
      create :metric, edition: edition1, date: 15.days.ago
      create :metric, edition: edition2, date: 15.days.ago
      recalculate_aggregations!
    end

    it "returns data from both organisations" do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expected_results = [edition1.base_path, edition2.base_path]
      expect(json[:results].map { |res| res[:base_path] }).to match_array(expected_results)
    end
  end

  describe "Filter by no organisation" do
    let(:edition1) { create :edition, primary_organisation_id: nil, date: 15.days.ago }

    subject { get "/content", params: { date_range: "past-30-days", organisation_id: "none" } }

    before do
      create :metric, edition: edition1, date: 15.days.ago
      edition2 = create :edition, primary_organisation_id:, date: 15.days.ago
      create :metric, edition: edition2, date: 15.days.ago
      recalculate_aggregations!
    end

    it "only returns data where organisation is null" do
      subject

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].map { |res| res[:base_path] }).to eq([edition1.base_path])
    end
  end

  describe "Sort by" do
    before do
      edition1 = create :edition, date: 1.month.ago, title: "A", document_type: "news_story"
      create :metric, date: 15.days.ago, edition: edition1, upviews: 10, useful_yes: 5, useful_no: 10, searches: 10

      edition2 = create :edition, date: 1.month.ago, title: "B", document_type: "guide"
      create :metric, date: 10.days.ago, edition: edition2, upviews: 100, useful_yes: 10, useful_no: 5, searches: 1

      edition3 = create :edition, date: 1.month.ago, title: "C", document_type: "homepage"
      create :metric, date: 10.days.ago, edition: edition3, upviews: 1, useful_yes: 10, useful_no: 10, searches: 100

      recalculate_aggregations!
    end

    sort_results = {
      'title': %w[A B C],
      'document_type': %w[B C A],
      'upviews': %w[C A B],
      'satisfaction': %w[A C B],
      'searches': %w[B A C],
    }

    sort_results.each do |sort_key, expected_values|
      it "sorts results by #{sort_key} attribute ascending" do
        get "/content", params: { date_range: "past-30-days", organisation_id: "all", sort: "#{sort_key}:asc" }

        response_body = JSON.parse(response.body).deep_symbolize_keys
        content_item_titles = response_body[:results].map { |i| i[:title] }
        expect(content_item_titles).to eq(expected_values)
      end

      it "sorts results by #{sort_key} attribute descending" do
        get "/content", params: { date_range: "past-30-days", organisation_id: "all", sort: "#{sort_key}:desc" }

        response_body = JSON.parse(response.body).deep_symbolize_keys
        content_item_titles = response_body[:results].map { |i| i[:title] }
        expect(content_item_titles).to eq(expected_values.reverse)
      end
    end
  end

  describe "Relevant content" do
    subject { get "/content", params: { date_range: "past-30-days", organisation_id: primary_organisation_id } }

    before do
      create_edition_and_metric("redirect")
      create_edition_and_metric("gone")
      create_edition_and_metric("news_story")
      create_edition_and_metric("vanish")
      create_edition_and_metric("unpublishing")
      create_edition_and_metric("need")
      recalculate_aggregations!
    end

    it "filters out `gone`, `redirect`, `vanish`, `unpublishing` and `need`" do
      subject
      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results].count).to eq(1)
      expect(json[:results].first).to include(document_type: "news_story")
    end
  end

  def create_edition_and_metric(document_type)
    edition = create(:edition,
                     document_type:,
                     date: 15.days.ago,
                     primary_organisation_id:)
    create :metric, edition:, date: 15.days.ago
    edition
  end

  describe "Pagination" do
    before do
      edition1 = create :edition, primary_organisation_id:, document_type: "a-document-type", base_path: "/path-01"
      create :metric, date: 15.days.ago, edition: edition1, upviews: 100, useful_yes: 50, useful_no: 20, searches: 20

      edition2 = create :edition, primary_organisation_id:, base_path: "/path-02"
      create :metric, date: 10.days.ago, edition: edition2, upviews: 10, useful_yes: 10, useful_no: 10, searches: 10

      recalculate_aggregations!
    end

    it "returns the first page of the data" do
      get "/content", params: { date_range: "past-30-days", organisation_id: primary_organisation_id, page: 1, page_size: 1 }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to contain_exactly(a_hash_including(base_path: "/path-01"))
      expect(json).to include(page: 1, total_pages: 2, total_results: 2)
    end

    it "returns the second page of the data" do
      get "/content", params: { date_range: "past-30-days", organisation_id: primary_organisation_id, page: 2, page_size: 1 }

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json[:results]).to contain_exactly(a_hash_including(base_path: "/path-02"))
      expect(json).to include(page: 2, total_pages: 2, total_results: 2)
    end
  end

  include_examples "API response", "/content", date_range: "past-30-days", organisation_id: "e12e3c54-b544-4d94-ba1f-9846144374d2"

  context "with invalid params" do
    it "returns an error for badly formatted dates" do
      get "/content", params: { date_range: "invalid-range", organisation_id: "386ea723-d8fc-4581-8e53-bb8ee9aa8c03" }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-data-api.publishing.service.gov.uk/errors.html#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "date_range" => ["this is not a valid date range"] },
      }

      expect(json).to eq(expected_error_response)
    end

    it "returns an error for invalid primary_organisation_id" do
      get "/content/", params: { date_range: "past-30-days", organisation_id: "blah" }

      expect(response.status).to eq(400)

      json = JSON.parse(response.body)

      expected_error_response = {
        "type" => "https://content-data-api.publishing.service.gov.uk/errors.html#validation-error",
        "title" => "One or more parameters is invalid",
        "invalid_params" => { "organisation_id" => ["this is not a valid organisation id"] },
      }

      expect(json).to eq(expected_error_response)
    end
  end
end
