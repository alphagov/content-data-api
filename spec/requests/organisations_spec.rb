RSpec.describe "/organisations" do
  before do
    create :user
  end

  it "returns distinct organisations ordered by title" do
    create :edition, document_type: "organisation", content_id: "org-1-id", title: "z Org"
    create :edition, document_type: "organisation", content_id: "org-2-id", title: "a Org", acronym: "HMRC"

    get "/api/v1/organisations"
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(
      organisations: [
        { name: "a Org", id: "org-2-id", acronym: "HMRC" },
        { name: "z Org", id: "org-1-id", acronym: nil },
      ],
    )
  end

  it "works with no editions" do
    get "/api/v1/organisations"
    json = JSON.parse(response.body).deep_symbolize_keys
    expect(json).to eq(organisations: [])
  end

  include_examples "API response", "/api/v1/organisations"
end
