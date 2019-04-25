RSpec.describe Streams::MessageProcessorJob do
  it 'increments `monitor.messages.*` ' do
    message = build(:message, routing_key: 'news_story.major')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.major")

    subject.perform(message.payload, message.delivery_info.routing_key)
  end

  context 'exception thrown during processing' do
    let(:message) { build(:message, routing_key: 'news_story.minor') }
    let(:exception) { StandardError.new('the error message') }
    let(:logger) { double('logger', error: nil) }

    before do
      allow_any_instance_of(Streams::Handlers::SingleItemHandler).to receive(:process).and_raise(exception)
      allow(Logger).to receive(:new).and_return(logger)
      allow(GovukError).to receive(:notify)
      subject.perform(message.payload, message.delivery_info.routing_key)
    end

    it 'logs the error message only' do
      expect(logger).to have_received(:error).once.with('the error message')
    end

    it 'sends the exception to sentry' do
      expect(GovukError).to have_received(:notify).with(exception)
    end
  end
end
