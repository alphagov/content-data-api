RSpec.describe Metric do
  EDITION_METRICS =
    %w[
      pdf_count
      doc_count
      readability
      sentences
      chars
      words
      reading_time
    ].freeze

  DAILY_METRICS =
    %w[
      entrances
      exits
      feedex
      useful_no
      useful_yes
      searches
      pviews
      upviews
    ].freeze

  describe ".find_all" do
    it "returns a list of all metrics" do
      metrics = Metric.find_all

      expect(metrics.length).to eq(16)
      a_metric = metrics.first
      expect(a_metric).to be_an_instance_of(Metric)
    end
  end

  describe ".find_all_names" do
    it "returns a list of all metrics" do
      metric_names = Metric.find_all_names

      expect(metric_names.length).to eq(16)
      a_metric = metric_names.first
      expect(a_metric).to eq("chars")
    end
  end

  describe ".is_edition_metric?" do
    EDITION_METRICS.each do |metric|
      it "returns true for #{metric}" do
        expect(Metric.is_edition_metric?(metric)).to be_truthy
      end
    end

    DAILY_METRICS.each do |metric|
      it "returns false for #{metric}" do
        expect(Metric.is_edition_metric?(metric)).to be_falsey
      end
    end
  end

  describe ".edition_metrics" do
    it "return the edition metrics" do
      metrics = Metric.edition_metrics
      expect(metrics.map(&:name)).to match_array(EDITION_METRICS)
    end
  end
end
