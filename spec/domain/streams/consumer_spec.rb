RSpec.describe Streams::Consumer do
  subject { described_class.new }
  it "increments `discard` in statsd when routing key is not valid" do
    message = build(:message, routing_key: "invalid_routing_key")
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded")

    subject.process(message)
  end

  it "sends an error to GovukError" do
    error = StandardError.new
    allow(Streams::MessageProcessorJob).to receive(:perform_later).and_raise(error)
    expect(GovukError).to receive(:notify).with(error)

    subject.process(build(:message))
  end
end
