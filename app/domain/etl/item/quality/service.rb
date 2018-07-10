require 'odyssey'

class Etl::Item::Quality::Service
  def run(content)
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
    result = Odyssey.flesch_kincaid_re(content, true)
    {
      readability_score: result.fetch('score'),
      string_length: result.fetch('string_length'),
      sentence_count: result.fetch('sentence_count'),
      word_count: result.fetch('word_count'),
    }.tap do |results|
      results[:contractions_count] = count_metric(response, 'contractions')
      results[:equality_count] = count_metric(response, 'equality')
      results[:indefinite_article_count] = count_metric(response, 'indefinite_article')
      results[:passive_count] = count_metric(response, 'passive')
      results[:profanities_count] = count_metric(response, 'profanities')
      results[:redundant_acronyms_count] = count_metric(response, 'redundant_acronyms')
      results[:repeated_words_count] = count_metric(response, 'repeated_words')
      results[:simplify_count] = count_metric(response, 'simplify')
      results[:spell_count] = count_metric(response, 'spell')
    end
  end

  def count_metric(response, metric_name)
    response.dig(metric_name, 'count') || 0
  end

  class QualityMetricsError < StandardError; end
end
