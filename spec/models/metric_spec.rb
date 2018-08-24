RSpec.describe Metric do
  EDITION_METRICS =
    %w(
      number_of_pdfs
      number_of_word_files
      readability_score
      sentence_count
      string_length
      word_count
    ).freeze

  DAILY_METRICS =
    %w(
      avg_time_on_page
      bounce_rate
      entrances
      exits
      feedex_comments
      is_this_useful_no
      is_this_useful_yes
      number_of_internal_searches
      pageviews
      unique_pageviews
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
