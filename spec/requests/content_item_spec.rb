require "rails_helper"

RSpec.describe "API::ContentItem", type: :request do
  let(:headers) { { "ACCEPT" => "application/json" } }

  describe "GET /content_items/{content-id}" do
    let!(:content_item) { create(:content_item, title: "A document title", content_id: "content-id-123") }

    it "returns JSON with the content item" do
      get "/content_items/content-id-123", headers: { "ACCEPT" => "application/json" }
      json = JSON.parse(response.body).deep_symbolize_keys

      expect(json).to include(title: "A document title")
    end
  end
end
