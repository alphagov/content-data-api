RSpec.describe "/api/v1/metrics/", type: :request do
  before { create(:user) }

  include_examples "API response", "/api/v1/metrics"

  describe "metrics index" do
    it "describes the available metrics" do
      get "/api/v1/metrics"

      json = JSON.parse(response.body)

      expect(json.count).to eq(::Metric.find_all.length)

      expect(json).to include("name" => "pviews",
                              "description" => "Number of pageviews",
                              "source" => "Google Analytics")
    end
  end
end
