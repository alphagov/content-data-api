class Metric
  EDITION_METRICS = %w(
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
    @all_metrics ||= YAML.load_file(Rails.root.join('config', 'metrics.yml')).sort_by { |metric| metric[:name] }
  end

  def self.valid_metric_names
    self.all_metrics.map { |metric| metric['name'] }
  end

  def self.is_edition_metric?(metric)
    EDITION_METRICS.include?(metric)
  end

  def self.content_metrics
    EDITION_METRICS
  end
end
