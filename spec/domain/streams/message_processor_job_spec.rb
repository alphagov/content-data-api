RSpec.describe Streams::MessageProcessorJob do
  it 'increments `monitor.messages.*` ' do
    message = build(:message, routing_key: 'news_story.major')
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.major")

    subject.perform(message.payload, message.delivery_info.routing_key)
  end
end
