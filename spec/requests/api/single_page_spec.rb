require "securerandom"

RSpec.describe "/single_page", type: :request do
  let!(:base_path) { "/base_path" }
  let!(:item) do
    create :edition,
           live: true,
           title: "the title",
           base_path:,
           content_id: "the-content-id",
           locale: "en",
           document_type: "guide",
           publishing_app: "whitehall",
           first_published_at: "2018-07-17T10:35:59.000Z",
           public_updated_at: "2018-07-17T10:35:57.000Z",
           primary_organisation_title: "The ministry",
           withdrawn: false,
           historical: false,
           facts: {
             'words': 30,
           }
  end

  before do
    create :user
    day1 = create :dimensions_date, date: Date.new(2018, 1, 1)
    day2 = create :dimensions_date, date: Date.new(2018, 1, 2)
    create :metric, dimensions_edition: item, dimensions_date: day1, pviews: 10, upviews: 10, useful_yes: 1, useful_no: 1
    create :metric, dimensions_edition: item, dimensions_date: day2, pviews: 20, upviews: 20, useful_yes: 10, useful_no: 0
  end

  context "when correct parameters supplied" do
    context "when the page is the homepage" do
      before do
        create :edition, base_path: "/", title: "GOV.UK homepage"
      end

      it "returns data for the homepage" do
        get "/single_page", params: { from: "2018-01-01", to: "2018-01-31" }

        body = JSON.parse(response.body).deep_symbolize_keys
        expect(response).to have_http_status(200)
        expect(body[:metadata][:title]).to eq("GOV.UK homepage")
      end
    end

    it "returns the metadata" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "metadata" => {
          "title" => "the title",
          "base_path" => base_path,
          "content_id" => "the-content-id",
          "locale" => "en",
          "document_type" => "guide",
          "publishing_app" => "whitehall",
          "first_published_at" => "2018-07-17T11:35:59.000+01:00",
          "public_updated_at" => "2018-07-17T11:35:57.000+01:00",
          "primary_organisation_title" => "The ministry",
          "withdrawn" => false,
          "historical" => false,
          "parent_document_id" => nil,
        },
      }
      expect(body["metadata"]).to include(expected["metadata"])
      expect(response).to have_http_status(:ok)
    end

    describe "number of related items" do
      before do
        day1 = create :dimensions_date, date: Date.new(2018, 1, 1)
        (1..4).each do |n|
          edition = create :edition, base_path: "/child-#{n}", parent: item
          create :metric, dimensions_edition: edition, dimensions_date: day1
        end
      end

      it "returns the count of children for the parent" do
        get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

        body = JSON.parse(response.body)

        expect(body).to include("number_of_related_content" => 4)
      end

      it "returns the count of siblings + parent for the child" do
        get "/single_page/child-1", params: { from: "2018-01-01", to: "2018-01-31" }

        body = JSON.parse(response.body)

        expect(body).to include("number_of_related_content" => 4)
      end
    end

    it "returns the time period" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "time_period" => {
          "from" => "2018-01-01",
          "to" => "2018-01-31",
        },
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "returns expected time series metrics" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      metric_names = Metric.daily_metrics.map(&:name)
      expected_metrics = metric_names.map do |metric_name|
        a_hash_including("name" => metric_name)
      end
      expected = {
        "time_series_metrics" => a_collection_including(*expected_metrics),
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "returns expected edition metrics" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      metric_names = Metric.edition_metrics.map(&:name)
      expected_metrics = metric_names.map do |metric_name|
        a_hash_including("name" => metric_name)
      end
      expected = {
        "edition_metrics" => a_collection_including(*expected_metrics),
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "returns the value of an edition metrics" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "edition_metrics" => a_collection_including(
          a_hash_including(
            "value" => 30,
            "name" => "words",
          ),
        ),
      }

      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "returns the aggregated values for each metric" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "time_series_metrics" => a_collection_including(
          a_hash_including(
            "name" => "upviews",
            "total" => 30,
          ),
        ),
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "returns the satisfaction score for time period" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "time_series_metrics" => a_collection_including(
          a_hash_including(
            "name" => "satisfaction",
            "total" => 0.9166666666666666,
          ),
        ),
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end

    it "returns the time series values for a time series metric" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01", to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "time_series_metrics" => a_collection_including(
          a_hash_including(
            "name" => "upviews",
            "time_series" => a_collection_including(
              { "date" => "2018-01-01", "value" => 10 },
              "date" => "2018-01-02",
              "value" => 20,
            ),
          ),
        ),
      }
      expect(body).to include(expected)
      expect(response).to have_http_status(:ok)
    end
  end

  context "with to param missing" do
    it "returns an error" do
      get "/single_page/#{base_path}", params: { from: "2018-01-01" }

      body = JSON.parse(response.body)

      expected = {
        "title" => "One or more parameters is invalid",
        "invalid_params" => {
          "to" => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD",
          ],
        },
        "type" => "https://content-data-api.publishing.service.gov.uk/errors.html#validation-error",
      }
      expect(body).to eq(expected)
      expect(response).to have_http_status(400)
    end
  end

  context "with from param missing" do
    it "returns an error" do
      get "/single_page/#{base_path}", params: { to: "2018-01-31" }

      body = JSON.parse(response.body)

      expected = {
        "title" => "One or more parameters is invalid",
        "invalid_params" => {
          "from" => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD",
          ],
        },
        "type" => "https://content-data-api.publishing.service.gov.uk/errors.html#validation-error",
      }
      expect(body).to eq(expected)
      expect(response).to have_http_status(400)
    end
  end

  context "with from and to params missing" do
    it "returns an error" do
      get "/single_page/#{base_path}"

      body = JSON.parse(response.body)

      expected = {
        "title" => "One or more parameters is invalid",
        "invalid_params" => {
          "from" => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD",
          ],
          "to" => [
            "can't be blank",
            "Dates should use the format YYYY-MM-DD",
          ],
        },
        "type" => "https://content-data-api.publishing.service.gov.uk/errors.html#validation-error",
      }
      expect(body).to eq(expected)
      expect(response).to have_http_status(400)
    end
  end
end
