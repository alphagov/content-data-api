RSpec.describe 'Import edition metrics' do
  include QualityMetricsHelpers

  subject { PublishingAPI::Consumer.new }

  it 'stores content item metrics' do
    message = build(:message, schema_name: 'publication', base_path: '/base-path')
    message.payload['details']['body'] = 'This is good content.'
    message.payload['details']['documents'] = [
      '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>',
      '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
    ]

    stub_quality_metrics_request
    subject.process(message)

    item = Dimensions::Item.first

    expect(item.facts_edition).to have_attributes(
      number_of_pdfs: 1,
      number_of_word_files: 1,
      readability_score: 97,
      string_length: 21,
      sentence_count: 1,
      word_count: 4,
      contractions_count: 2,
      equality_count: 3,
      indefinite_article_count: 4,
      passive_count: 5,
      profanities_count: 6,
      redundant_acronyms_count: 7,
      repeated_words_count: 8,
      simplify_count: 9,
      spell_count: 10,
    )
  end

  def stub_quality_metrics_request
    stub_quality_metrics(
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
    )
  end
end
