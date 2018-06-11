module QualityMetricsHelpers
  def stub_quality_metrics(options = {})
    response = {
      readability: { 'count' => 1 },
      contractions: { 'count' => 2 },
      equality: { 'count' => 3 },
      indefinite_article: { 'count' => 4 },
      passive: { 'count' => 5 },
      profanities: { 'count' => 6 },
      redundant_acronyms: { 'count' => 7 },
      repeated_words: { 'count' => 8 },
      simplify: { 'count' => 9 },
      spell: { 'count' => 10 }
    }.merge!(options)

    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics').
      to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
