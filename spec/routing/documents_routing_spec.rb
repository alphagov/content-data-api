RSpec.describe "documents endpoint routing" do
  it "routes /documents/1234/children" do
    expect(get: "api/v1/documents/1234/children").to route_to(
      controller: "api/documents",
      action: "children",
      format: :json,
      document_id: "1234",
    )
  end
end
