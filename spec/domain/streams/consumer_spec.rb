RSpec.describe Streams::Consumer do
  subject { described_class.new }
  it "increments `discard` in statsd when routing key is not valid" do
    message = build(:message, routing_key: "invalid_routing_key")
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded")

    subject.process(message)
  end

  it "sends payload information to GovukError" do
    error = StandardError.new
    allow(Streams::MessageProcessorJob).to receive(:perform_later).and_raise(error)
    expect(GovukError).to receive(:notify).with(error, extra: { payload: hash_including(
      "content_id" => an_instance_of(String),
      "base_path" => an_instance_of(String),
      # there are many more properties, but these are the only ones we need for debugging
    ) })

    subject.process(build(:message))
  end
end
