RSpec.describe Metric do
  EDITION_METRICS =
    %w(
      pdf_count
      doc_count
      readability
      sentences
      chars
      words
    ).freeze

  DAILY_METRICS =
    %w(
      avg_page_time
      bounce_rate
      entrances
      exits
      feedex
      useful_no
      useful_yes
      searches
      pviews
      upviews
    ).freeze

  describe '.find_all' do
    it "returns a list of all metrics" do
      metrics = Metric.find_all

      expect(metrics.length).to eq(17)
      a_metric = metrics.first
      expect(a_metric).to be_an_instance_of(Metric)
    end
  end

  describe '.is_edition_metric?' do
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

  describe '.edition_metrics' do
    it 'return the edition metrics' do
      metrics = Metric.edition_metrics
      expect(metrics.map(&:name)).to match_array(EDITION_METRICS)
    end
  end
end
