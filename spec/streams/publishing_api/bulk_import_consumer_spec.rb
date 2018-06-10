require 'govuk_message_queue_consumer/test_helpers'
require 'gds_api/test_helpers/content_store'

RSpec.describe PublishingAPI::BulkImportConsumer do
  include GdsApi::TestHelpers::ContentStore

  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  context 'when an error happens' do
    let!(:message) { build :message }

    before { expect(PublishingAPI::MessageHandler).to receive(:process).and_raise(StandardError.new("An error")) }

    it "logs the error" do
      expect(GovukError).to receive(:notify).with(instance_of(StandardError))

      expect { subject.process(message) }.to_not raise_error
    end

    it "discards the message" do
      expect(message).to receive(:discard)

      subject.process(message)
    end
  end
end
