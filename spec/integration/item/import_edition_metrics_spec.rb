RSpec.describe 'Import edition metrics' do
  include QualityMetricsHelpers

  subject { PublishingAPI::Consumer.new }

  it 'stores content item metrics' do
    message = build(:message, schema_name: 'publication', base_path: '/new-path')
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

  it 'clones the existing edition if the content has not changed' do
    item = create(:dimensions_item,
      base_path: '/same-content',
      document_text: 'the same content',
      publishing_api_payload_version: 1,
      latest: true)

    create(:facts_edition,
      dimensions_item: item,
      dimensions_date: Dimensions::Date.for(Date.today),
      repeated_words_count: 1)
    message = build(:message,
      schema_name: 'publication',
      base_path: '/same-content',
      payload_version: 2)
    message.payload['details']['body'] = '<p>the same content</p>'

    stub_quality_metrics_request
    subject.process(message)

    expect(find_latest_edition('/same-content').repeated_words_count).to eq(1)
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

  def find_latest_edition(base_path)
    Dimensions::Item.latest_by_base_path([base_path]).first.facts_edition
  end
end
