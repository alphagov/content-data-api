require 'sidekiq/testing'
require 'govuk_message_queue_consumer/test_helpers'
require 'gds_api/test_helpers/content_store'

RSpec.describe PublishingAPI::Consumer do
  include GdsApi::TestHelpers::ContentStore

  around do |example|
    Sidekiq::Testing.inline! do
      example.run
    end
  end

  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  context 'when the Dimensions::Item already exists - all events but unpublish' do
    let!(:latest_item_en) do
      create(:dimensions_item, locale: 'en', publishing_api_payload_version: 1)
    end
    let!(:latest_item_de) do
      create(:dimensions_item, locale: 'de', publishing_api_payload_version: 1)
    end

    let!(:older_item) do
      create(:dimensions_item,
        content_id: latest_item_en.content_id,
        base_path: latest_item_en.base_path,
        latest: false,
        publishing_api_payload_version: 1)
    end
    let!(:different_item) { create(:dimensions_item) }
    let!(:updated_base_path) { '/updated/base/path' }
    let!(:updated_title) { 'new title' }
    let!(:updated_document_type) { 'guide' }
    let!(:payload) do
      {
        'base_path' => updated_base_path,
        'content_id' => latest_item_de.content_id,
        'locale' => 'de',
        'payload_version' => 2,
        'title' => updated_title,
        'document_type' => updated_document_type
      }
    end
    let!(:message) do
      double('message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'news_story.major'))
    end

    before :each do
      allow(message).to receive(:ack)

      stub_content_store_response(
        content_id: latest_item_de.content_id,
        base_path: updated_base_path,
        body: "News about things",
        document_type: updated_document_type,
        title: updated_title
      )

      stub_quality_metrics_response("News about things")

      subject.process(message)
    end

    it 'marks the existing item as not-latest' do
      expect(latest_item_de.reload.latest).to be false
      expect(latest_item_en.reload.latest).to be true
    end

    it 'creates a new latest item with the same locale and content_id but updated base path' do
      new_item = Dimensions::Item.find_by(content_id: latest_item_de.content_id, locale: 'de', latest: true)

      expect(new_item).not_to be_nil
      expect(new_item.base_path).to eq(updated_base_path)
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end

    it "populates metadata for the new item" do
      new_item = Dimensions::Item.find_by(content_id: latest_item_de.content_id, locale: 'de', latest: true)

      expect(new_item).to have_attributes(
        title: updated_title,
        document_type: updated_document_type,
      )
    end
  end

  context 'when the Dimensions::Item already exists - links update' do
    let!(:latest_item_en) do
      create(:dimensions_item, locale: 'en', publishing_api_payload_version: 1, base_path: "/foo")
    end

    let(:links) do
      {
        "primary_publishing_organisation" => [
          { "content_id": "abc", "title": "ministry of silly walks", "withdrawn": false }
        ]
      }
    end

    let(:payload) do
      {
        'base_path' => latest_item_en.base_path,
        'content_id' => latest_item_en.content_id,
        'locale' => 'en',
        'payload_version' => 2,
        'title' => latest_item_en.title,
        'document_type' => latest_item_en.document_type,
        'expanded_links' => links
      }
    end

    let(:message) do
      double('message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'news_story.links'))
    end

    before :each do
      allow(message).to receive(:ack)

      stub_content_store_response(
        content_id: latest_item_en.content_id,
        base_path: latest_item_en.base_path,
        body: "News about things",
        document_type: latest_item_en.document_type,
        title: latest_item_en.title,
        links: links
      )

      stub_quality_metrics_response("News about things")

      subject.process(message)
    end

    it 'keeps the latest item as the latest item' do
      expect(latest_item_en.reload.latest).to be true
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end

    it "updates the latest item" do
      expect(latest_item_en.reload).to have_attributes(
        primary_organisation_content_id: "abc",
        primary_organisation_title: "ministry of silly walks",
        primary_organisation_withdrawn: false
      )
    end
  end


  context 'on an unpublish event' do
    let!(:latest_item_en) do
      create(:dimensions_item, locale: 'en', publishing_api_payload_version: 1)
    end
    let!(:latest_item_fr) do
      create(:dimensions_item, locale: 'fr', publishing_api_payload_version: 1)
    end
    let!(:payload) do
      {
        'base_path' => latest_item_en.base_path,
        'content_id' => latest_item_en.content_id,
        'locale' => 'en',
        'payload_version' => 2
      }
    end
    let!(:message) do
      double('message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'gone.unpublish'))
    end

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'creates a new gone item with the same locale and content_id' do
      new_item = Dimensions::Item.find_by(content_id: latest_item_en.content_id, locale: 'en', latest: true)

      expect(new_item).not_to be_nil
      expect(new_item.reload.status).to eq('gone')
    end

    it 'updates the latest flag for the previous item' do
      expect(latest_item_en.reload.latest).to be false
      expect(latest_item_fr.reload.latest).to be true
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end

  context 'when the Dimensions::Item does not exist yet' do
    let!(:payload) do
      {
        'base_path' => '/path/to/new/content',
        'content_id' => 'does-not-exist-yet',
        'locale' => 'en',
        'payload_version' => 1
      }
    end
    let!(:message) do
      double('message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'news_story.major'))
    end

    before :each do
      allow(message).to receive(:ack)
      subject.process(message)
    end

    it 'creates a new item with the correct base path' do
      item = Dimensions::Item.where(content_id: payload['content_id']).first

      expect(item).to have_attributes(
        base_path: payload['base_path'],
        latest: true,
      )
    end

    it "ack's the message" do
      expect(message).to have_received(:ack)
    end
  end

  context 'when locale is not present' do
    let!(:message) do
      double('message',
        payload: {
          'base_path' => '/path/to/new/content',
          'content_id' => 'the_content_id',
          'payload_version' => 1
        },
        delivery_info: double('del_info', routing_key: 'news_story.major'))
    end

    it "creates a new item with the 'en' locale" do
      allow(message).to receive(:ack)
      subject.process(message)

      item = Dimensions::Item.find_by(content_id: 'the_content_id')
      expect(item).to have_attributes(locale: 'en')
    end

    it "ack's the message" do
      expect(message).to receive(:ack)

      subject.process(message)
    end
  end

  context "when an error happens" do
    let!(:message) do
      double('message',
        payload: {
          'base_path' => '/path/to/new/content',
          'content_id' => 'the_content_id',
          'payload_version' => 1
        },
        delivery_info: double('del_info', routing_key: 'news_story.major'))
    end

    before do
      allow(message).to receive(:discard)
      expect(Dimensions::Item).to receive(:by_natural_key).and_raise(StandardError.new("An error"))
    end

    it "we log the error" do
      expect(GovukError).to receive(:notify).with(instance_of(StandardError))

      expect { subject.process(message) }.to_not raise_error
    end

    it "we discard the message" do
      expect(message).to receive(:discard)

      subject.process(message)
    end
  end

  context 'receiving messages out of order' do
    let(:content_id) { SecureRandom.uuid }
    let(:base_path) { "/foo" }
    let(:locale) { "en" }
    let(:message) { build_publishing_api_message(base_path, content_id, locale, payload_version: 1) }
    let(:another_message) { build_publishing_api_message(base_path, content_id, locale, payload_version: 2) }

    it 'ignores repeated messages' do
      subject.process(message)
      subject.process(message)

      expect(Dimensions::Item.count).to eq(1)
      expect(Dimensions::Item.first.publishing_api_payload_version).to eq(1)
    end

    it 'ignores messages with old payload versions' do
      subject.process(another_message)
      subject.process(message)

      expect(Dimensions::Item.count).to eq(1)
      expect(Dimensions::Item.first.publishing_api_payload_version).to eq(2)
    end
  end

  def stub_content_store_response(content_id:, base_path:, title:, body:, document_type:, schema_name: 'news_article', links: nil)
    response = content_item_for_base_path(base_path)
    response.merge!(
      'content_id' => content_id,
      'base_path' => base_path,
      'schema_name' => schema_name,
      'title' => title,
      'document_type' => document_type,
      'details' => {
        'body' => body,
      }
    )

    if links
      response["links"] = links
    end

    content_store_has_item(base_path, response, {})
  end

  def stub_quality_metrics_response(item_content)
    quality_metrics_response = {
      passive: { 'count' => 5 },
      repeated_words: { 'count' => 8 },
    }
    stub_request(:post, 'https://govuk-content-quality-metrics.cloudapps.digital/metrics').
      with(
        body: { content: item_content }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
      .to_return(
        status: 200,
        body: quality_metrics_response.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def build_publishing_api_message(base_path, content_id, locale, payload_version: 1)
    message = double('message',
      payload: {
        'base_path' => base_path,
        'content_id' => content_id,
        'locale' => locale,
        'payload_version' => payload_version
      },
      delivery_info: double('del_info', routing_key: 'news_story.major'))
    allow(message).to receive(:ack)

    message
  end
end
