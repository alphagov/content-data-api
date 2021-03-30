RSpec.describe "/healthcheck/metrics" do
  before do
    get "/healthcheck/metrics"
  end

  it "returns distinct organisations ordered by title" do
    json = JSON.parse(response.body)

    expect(json["checks"]).to include("daily_metrics")
    .and(include("etl_metric_values_pviews"))
    .and(include("etl_metric_values_searches"))
    .and(include("etl_metric_values_upviews"))
    .and(include("etl_metric_values_feedex"))
  end

  it "is not cacheable" do
    expect(response.headers["Cache-Control"]).to eq "max-age=0, private, must-revalidate"
  end
end
