RSpec.describe Metric do
  let(:content_metric) { "word_count" }
  let(:performance_metric) { "pageviews" }

  it "returns a list of all metrics" do
    metrics = Metric.all_metrics

    expect(metrics.length).to eq(25)
    a_metric = metrics.first
    expect(a_metric).to be_an_instance_of(Hash)
    expect(a_metric).to include('description', 'name')
  end

  describe '.is_content_metric' do
    %w(
    number_of_pdfs
    number_of_word_files
    readability_score
    contractions_count
    equality_count
    indefinite_article_count
    passive_count
    profanities_count
    redundant_acronyms_count
    repeated_words_count
    simplify_count
    spell_count
    string_length
    sentence_count
    word_count
    ).each do |metric|
      it "returns true for #{metric}" do
        expect(Metric.is_content_metric?(metric)).to be_truthy
      end
    end

    %w(
    pageviews
    unique_pageviews
    feedex_comments
    is_this_useful_no
    is_this_useful_yes
    number_of_internal_searches
    entrances
    exits
    bounce_rate
    avg_time_on_page
    ).each do |metric|
      it "returns false for #{metric}" do
        expect(Metric.is_content_metric?(metric)).to be_falsey
      end
    end
  end

  it "returns a list of content metrics" do
    metrics = Metric.content_metrics

    expect(metrics).to include(content_metric)
    expect(metrics).to_not include(performance_metric)
  end
end
