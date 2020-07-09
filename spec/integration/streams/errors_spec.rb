require "sidekiq/testing"
require "govuk_message_queue_consumer/test_helpers"
require "gds_api/test_helpers/content_store"

RSpec.describe Streams::Consumer do
  # FIXME: Rails 6 inconsistently overrides ActiveJob queue_adapter setting
  # with TestAdapter #37270
  # See https://github.com/rails/rails/issues/37270
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:subject) { described_class.new }

  it_behaves_like "a message queue processor"

  let!(:message) { build :message }

  context "when an error happens" do
    before do
      expect_any_instance_of(Streams::Messages::SingleItemMessage).to receive(:invalid?).and_raise(StandardError.new)
    end

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
    before do
      allow_any_instance_of(Streams::Messages::SingleItemMessage).to receive(:invalid?).and_raise(StandardError)
    end

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
