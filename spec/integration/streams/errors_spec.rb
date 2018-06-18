require 'sidekiq/testing'
require 'govuk_message_queue_consumer/test_helpers'
require 'gds_api/test_helpers/content_store'

RSpec.describe PublishingAPI::Consumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  let!(:message) { build :message }

  context 'when an error happens' do
    before {
      expect(PublishingAPI::MessageHandler).to receive(:process).and_raise(StandardError.new)
    }

    it "logs the error" do
      expect(GovukError).to receive(:notify).with(instance_of(StandardError))

      expect { subject.process(message) }.to_not raise_error
    end

    it "discards the message" do
      expect(message).to receive(:discard)

      subject.process(message)
    end
  end

  context "when message has missing mandatory field 'base_path'" do
    before {
      allow(PublishingAPI::MessageHandler).to receive(:process).and_raise(StandardError)
    }

    it "logs the error" do
      message.payload.delete('base_path')

      expect(GovukError).to receive(:notify).with(StandardError.new, extra: { payload: message })
      expect { subject.process(message) }.to_not raise_error
    end

    it "discards the message" do
      expect(message).to receive(:discard)

      subject.process(message)
    end
  end
end
