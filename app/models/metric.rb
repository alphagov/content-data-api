class Metric
  CONTENT_METRICS = %w(
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
    ).freeze

  def self.all_metrics
    Rails.configuration.metrics
  end

  def self.is_content_metric?(metric)
    CONTENT_METRICS.include?(metric)
  end

  def self.content_metrics
    CONTENT_METRICS
  end
end
