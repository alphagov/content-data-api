RSpec.describe Metric do
  let(:content_metric) { "word_count" }
  let(:performance_metric) { "pageviews" }

  it "returns a list of all metrics" do
    metrics = Metric.all_metrics

    expect(metrics).to include(content_metric)
    expect(metrics).to include(performance_metric)
  end

  it "checks if a metric is a content metric" do
    expect(Metric.is_content_metric?(content_metric)).to be true
  end

  it "returns a list of content metrics" do
    metrics = Metric.content_metrics

    expect(metrics).to include(content_metric)
    expect(metrics).to_not include(performance_metric)
  end
end
