require 'govuk_message_queue_consumer/test_helpers'
require 'gds_api/test_helpers/content_store'

RSpec.describe PublishingAPI::BulkImportConsumer do
  include GdsApi::TestHelpers::ContentStore

  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  context "given a detailed guide" do
    let!(:payload) do
      GovukSchemas::RandomExample.for_schema(notification_schema: "detailed_guide") do |payload|
        payload.merge('document_type' => 'detailed_guide', 'locale' => 'en')
      end
    end

    # Remove this once we no longer call content store
    let(:content_store_payload) do
      GovukSchemas::RandomExample.for_schema(frontend_schema: "detailed_guide") do |example|
        example.merge!(
          payload.slice("content_id", "base_path", "document_type", "schema_name", "locale", "public_updated_at", "first_published_at", "title")
        )
      end
    end

    let(:message) do
      double(
        'message',
        payload: payload,
        delivery_info: double('del_info', routing_key: 'detailed_guide.bulk.data-warehouse')
      )
    end

    before do
      content_store_has_item(content_store_payload["base_path"], content_store_payload, {})

      allow(message).to receive(:ack)
    end

    it "creates a new item record with format detailed guide and latest=True" do
      subject.process(message)

      expect(Dimensions::Item.count).to eq(1)
      item = Dimensions::Item.first
      expect(item.document_type).to eq('detailed_guide')
      expect(item.latest).to be true
    end

    it "schedules a quality metric update job" do
      expect(Items::Jobs::ImportQualityMetricsJob).to receive(:perform_async)

      subject.process(message)
    end

    it "hashes the content" do
      subject.process(message)

      item = Dimensions::Item.first
      expect(item.content_hash).to be_present
    end

    it "stores metadata about the content" do
      subject.process(message)

      item = Dimensions::Item.first

      expect(item).to have_attributes(
        content_id: payload["content_id"],
        base_path: payload["base_path"],
        locale: payload["locale"],
        title: payload["title"],
      )
    end

    it "is idempotent" do
      subject.process(message)
      subject.process(message)

      expect(Dimensions::Item.count).to eq(1)
    end
  end

  context "given a multi-part guide"
end
