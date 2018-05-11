RSpec.describe Metric do
  it "returns a list of all metrics" do
    metrics = Metric.all_metrics

    expect(metrics).to include("number_of_pdfs")
  end

  it "checks if a metric is a content metric" do
    metric = "number_of_pdfs"

    expect(Metric.is_content_metric?(metric)).to be true
  end
end
