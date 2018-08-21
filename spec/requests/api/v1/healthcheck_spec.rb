RSpec.describe '/api/v1/healthcheck/', type: :request do
  it "is not cacheable" do
    get "/api/v1/healthcheck/"

    expect(response.headers['Cache-Control']).to eq "max-age=0, private, must-revalidate"
  end
end
