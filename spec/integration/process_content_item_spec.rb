require 'sidekiq/testing'
require 'gds_api/test_helpers/content_store'

RSpec.describe 'Process content item' do
  include GdsApi::TestHelpers::ContentStore

  around do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  let(:content_id) { 'id1' }
  let(:base_path) { '/the-base-path' }
  let(:item_content) { 'This is the content.' }
  let(:content_hash) { 'bfce49ef213b4f9f82a6a46caae2d81a4bcda1f2' }
  let(:locale) { 'en' }

  let!(:item) {
    create :dimensions_item,
      content_id: content_id, base_path: base_path,
      locale: locale,
      content_hash: 'OldContentHash'
  }

  it 'stores metadata in quality metrics for a content item' do
    stub_item_metadata_in_content_store
    stub_quality_metrics_in_heroku

    Items::Importers::ContentDetails.run(item.id)

    expect(item.reload).to have_attributes(
      content_id: content_id,
      base_path: base_path,
      title: 'title1',
      document_type: 'document_type1',
      content_purpose_document_supertype: 'content_purpose_document_supertype1',
      content_purpose_supergroup: 'content_purpose_supergroup1',
      content_purpose_subgroup: 'content_purpose_subgroup1',
      first_published_at: Time.new(2018, 2, 19),
      public_updated_at: Time.new(2018, 2, 19),
      number_of_pdfs: 2,
      number_of_word_files: 2,
    )

    expect(item).to have_attributes(
      readability_score: 97,
      string_length: 20,
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

    expect(item).to have_attributes(
      primary_organisation_title: 'Home Office',
      primary_organisation_content_id: 'cont-id-1',
      primary_organisation_withdrawn: false
    )

    expect(item).to have_attributes(
      content_hash: content_hash
    )
  end

  context 'quality metrics in facts edition' do
    it 'stores quality metrics in the facts edition' do
      stub_item_metadata_in_content_store
      stub_quality_metrics_in_heroku
      Items::Importers::ContentDetails.run(item.id)
      facts_edition = Facts::Edition.find_by(dimensions_item: item)

      expect(facts_edition).to have_attributes(
        readability_score: 97,
        string_length: 20,
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
  end

  def stub_item_metadata_in_content_store
    response = content_item_for_base_path(base_path)
    response.merge!(
      'content_id' => content_id,
      'base_path' => base_path,
      'locale' => 'en',
      'schema_name' => 'news_article',
      'title' => 'title1',
      'document_type' => 'document_type1',
      'content_purpose_document_supertype' => 'content_purpose_document_supertype1',
      'content_purpose_supergroup' => 'content_purpose_supergroup1',
      'content_purpose_subgroup' => 'content_purpose_subgroup1',
      'first_published_at' => Time.new(2018, 2, 19).to_s,
      'public_updated_at' => Time.new(2018, 2, 19).to_s,
      'details' => {
        'documents' => [
          '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>',
          '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
        ],
        'final_outcome_documents' => [
          '<div class=\"attachment-details\">\n<a href=\"link.pdf\">1</a>\n\n\n\n</div>',
          '<div class=\"attachment-details\">\n<a href=\"link.docx\">1</a>\n\n\n\n</div>',
        ],
        'body' => item_content,
      },
      'links' => {
        'primary_publishing_organisation' => [{
          'title' => 'Home Office',
          'content_id' => 'cont-id-1',
          'withdrawn' => false
        }]
      }
    )
    content_store_has_item(base_path, response, {})
  end

  def stub_quality_metrics_in_heroku
    quality_metrics_response = {
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
    }
    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics').
      with(
        body: "{\"content\":\"#{item_content}\"}",
        headers: { 'Content-Type' => 'application/json' }
      ).
      to_return(status: 200, body: quality_metrics_response.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
