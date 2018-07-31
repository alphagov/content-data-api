require 'sidekiq/testing'
RSpec.describe 'Import edition metrics' do
  include QualityMetricsHelpers
  include ItemSetupHelpers
  include ActiveJob::TestHelper

  subject { PublishingAPI::MessageHandler }

  around do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  xit 'stores content item metrics', perform_enqueued: true do
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

  let(:existing_quality_metrics) do
    {
      repeated_words_count: 1,
      word_count: 3,
      equality_count: 2,
      indefinite_article_count: 2,
      passive_count: 6
    }
  end

  it 'clones the existing edition if the content has not changed' do
    create_edition(
      base_path: '/same-content',
      date: Date.today,
      item: {
        document_text: 'the same content',
        publishing_api_payload_version: 1,
        latest: true
      },
      edition: existing_quality_metrics
    )

    message = build(:message,
      schema_name: 'publication',
      base_path: '/same-content',
      payload_version: 2)
    message.payload['details']['body'] = '<p>the same content</p>'

    stub_quality_metrics_request
    subject.process(message)

    expect(find_latest_edition('/same-content')).to have_attributes(existing_quality_metrics)
  end

  it 'clones the existing edition if the content is nil on old and new items' do
    create_edition(
      base_path: '/empty-content',
      date: Date.today,
      item: {
        document_text: nil,
        publishing_api_payload_version: 1,
        latest: true
      },
      edition: existing_quality_metrics
    )

    message = build(:message,
      schema_name: 'publication',
      base_path: '/empty-content',
      payload_version: 2)
    message.payload['details']['body'] = nil

    stub_quality_metrics_request
    subject.process(message)

    expect(find_latest_edition('/empty-content')).to have_attributes(existing_quality_metrics)
  end

  def stub_quality_metrics_request
    stub_quality_metrics(
      readability_count: 1,
      contractions_count: 2,
      equality_count: 3,
      indefinite_article_count: 4,
      passive_count: 5,
      profanities_count: 6,
      redundant_acronyms_count: 7,
      repeated_words_count: 8,
      simplify_count: 9,
      spell_count: 10
    )
  end

  def find_latest_edition(base_path)
    Dimensions::Item.latest_by_base_path([base_path]).first.facts_edition
  end
end
