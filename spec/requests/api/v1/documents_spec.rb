RSpec.describe '/api/v1/documents/:document_id/children', type: :request do
  include AggregationsSupport

  before { create(:user) }
  let(:content_id) { SecureRandom.uuid }
  let(:locale) { 'en' }
  let(:time_period) { 'past-30-days' }

  describe "documents show" do
    it "describes a documents with no children" do
      _, parent_response = setup_edition_and_metrics(content_id, locale, 10)

      get "/api/v1/documents/#{content_id}:#{locale}/children?time_period=#{time_period}"

      json = JSON.parse(response.body)

      expect(json).to include("documents" => [parent_response])
    end

    it "describes a documents with children" do
      parent, parent_response = setup_edition_and_metrics(content_id, locale, 10)
      _, child1_response = setup_edition_and_metrics(SecureRandom.uuid, locale, 11, parent: parent, order: 1)
      _, child2_response = setup_edition_and_metrics(SecureRandom.uuid, locale, 12, parent: parent, order: 2)

      get "/api/v1/documents/#{content_id}:#{locale}/children?time_period=#{time_period}"

      json = JSON.parse(response.body)

      expect(json).to include("documents" => [parent_response, child1_response, child2_response])
    end

    it "describes the children documents when parent does not exist" do
      get "/api/v1/documents/wrong-id:en/children?time_period=#{time_period}"

      json = JSON.parse(response.body)

      expect(json).to include(
        "title" => "The parent document you are looking for cannot be found",
        "invalid_params" => %w(document_id)
      )

      expect(response).to have_http_status(404)
    end
  end
end

def setup_edition_and_metrics(content_id, locale, total_upviews, parent: nil, order: nil)
  edition = create :edition, content_id: content_id, locale: locale, live: true, parent: parent, sibling_order: order

  create :metric, edition: edition, date: Date.yesterday, upviews: 0, pviews: 1, useful_yes: 1, useful_no: 1, searches: 1
  create :metric, edition: edition, date: 10.days.ago, upviews: total_upviews, pviews: 1, useful_yes: 74, useful_no: 24, searches: 2

  recalculate_aggregations!

  response = {
    "base_path" => edition.base_path,
    "title" => edition.title,
    "primary_organisation_id" => edition.primary_organisation_id,
    "document_type" => edition.document_type,
    "sibling_order" => order,
    "upviews" => total_upviews,
    "pviews" => 2,
    "feedex" => 0,
    "useful_yes" => 75,
    "useful_no" => 25,
    "satisfaction" => 0.75,
    "searches" => 3
  }
  [edition, response]
end
