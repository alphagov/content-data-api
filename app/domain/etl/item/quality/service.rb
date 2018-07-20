require 'odyssey'

class Etl::Item::Quality::Service
  def run(content)
    return {} if content.blank?

    parsed_response = fetch(content)
    convert_results(parsed_response, content)
  end

private

  URL = 'https://govuk-content-quality-metrics.cloudapps.digital/metrics'.freeze

  def fetch(content)
    response = HTTParty.post(
      URL,
      body: { content: content }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
    raise QualityMetricsError.new("response body: #{response.body}") unless response.code == 200
    response.parsed_response
  end

  def convert_results(response, content)
    result_fields = %w[
    contractions_count
    equality_count
    indefinite_article_count
    passive_count
    profanities_count
    redundant_acronyms_count
    repeated_words_count
    simplify_count
    spell_count
]
    result = Odyssey.flesch_kincaid_re(content, true)
    response.slice(*result_fields).symbolize_keys.merge(
      readability_score: result.fetch('score'),
      string_length: result.fetch('string_length'),
      sentence_count: result.fetch('sentence_count'),
      word_count: result.fetch('word_count'),
    )
  end

  def count_metric(response, metric_name)
    response.dig(metric_name) || 0
  end
end

class QualityMetricsError < StandardError;
end
