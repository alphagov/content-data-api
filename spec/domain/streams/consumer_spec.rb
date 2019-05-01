RSpec.describe Streams::Consumer do
  subject { described_class.new }
  it 'increments `discard` in statsd when error is raised' do
    message = build(:message)
    allow(Streams::MessageProcessorJob).to receive(:perform_later).and_raise(StandardError)
    expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded")

    subject.process(message)
  end
end
