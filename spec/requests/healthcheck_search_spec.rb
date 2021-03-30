RSpec.describe "/healthcheck/search" do
  before do
    get "/healthcheck/search"
  end

  it "returns distinct organisations ordered by title" do
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("aggregations")
      .and(include("search_last_month"))
      .and(include("search_last_six_months"))
      .and(include("search_last_thirty_days"))
      .and(include("search_last_three_months"))
      .and(include("search_last_twelve_months"))
  end

  it "is not cacheable" do
    expect(response.headers["Cache-Control"]).to eq "max-age=0, private, must-revalidate"
  end
end
