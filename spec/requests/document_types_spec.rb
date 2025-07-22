RSpec.describe "/document_types" do
  before do
    create :user
  end

  it "returns distinct document types ordered by title" do
    create :edition, document_type: "guide"
    create :edition, document_type: "manual"
    create :edition, document_type: "manual"
    # the document types below should not appear in the results
    create :edition, document_type: "redirect"
    create :edition, document_type: "gone"
    create :edition, document_type: "vanish"
    create :edition, document_type: "unpublishing"
    create :edition, document_type: "need"
    create :edition, document_type: "substitute"

    get "/api/v1/document_types"
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(document_types: [
      { id: "guide", name: "Guide" },
      { id: "manual", name: "Manual" },
    ])
  end

  it "works with no editions" do
    get "/api/v1/document_types"
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(document_types: [])
  end

  include_examples "API response", "/api/v1/document_types"
end
