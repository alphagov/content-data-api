RSpec.describe "/healthcheck" do
  it "returns distinct organisations ordered by title" do
    get "/healthcheck"
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("database_status")
      .and(include("etl_metric_values_pviews"))
      .and(include("etl_metric_values_upviews"))
      .and(include("etl_metric_values_feedex"))
  end

  it "returns database connection status" do
    get "/healthcheck"
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("database_connectivity")
  end

  it "returns Redis connection status" do
    get "/healthcheck"
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("redis_connectivity")
  end

  it "is not cacheable" do
    get "/healthcheck"

    expect(response.headers["Cache-Control"]).to eq "max-age=0, private, must-revalidate"
  end
end
