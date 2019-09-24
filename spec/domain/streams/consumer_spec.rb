RSpec.describe Streams::Consumer do
  subject { described_class.new }
  it "increments `discard` in statsd when routing key is not valid" do
    message = build(:message, routing_key: "invalid_routing_key")
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded")

    subject.process(message)
  end
end
