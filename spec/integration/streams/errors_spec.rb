require 'sidekiq/testing'
require 'govuk_message_queue_consumer/test_helpers'
require 'gds_api/test_helpers/content_store'

RSpec.describe Streams::Consumer do
  let(:subject) { described_class.new }

  it_behaves_like 'a message queue processor'

  let!(:message) { build :message }

  context 'when an error happens' do
    before {
      expect_any_instance_of(Streams::Payloads::SingleItemPayload).to receive(:valid?).and_raise(StandardError.new)
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

  context "when message has missing mandatory fields" do
    before {
      allow_any_instance_of(Streams::Payloads::SingleItemPayload).to receive(:valid?).and_raise(StandardError)
    }

    context "missing field is base_path" do
      it "discards the message" do
        expect(message).to receive(:discard)

        subject.process(message)
      end
    end

    context "missing field is schema_name" do
      it "discards the message" do
        expect(message).to receive(:discard)

        subject.process(message)
      end
    end
  end
end
