RSpec.describe Streams::Consumer do
  subject { described_class.new }

  context 'with valid payload' do
    let(:message) { build(:message) }

    it 'acknowledges the message' do
      subject.process(message)
      expect(message).to be_acked
    end

    it 'increments routing_key in statsd' do
      expect(GovukStatsd).to receive(:increment).with("monitor.messages.acknowledged.major")
      subject.process(message)
    end
  end

  context 'with invalid payload' do
    let(:message) { build(:message, schema_name: 'placeholder') }

    it 'discards the message' do
      subject.process(message)
      expect(message).to be_discarded
    end

    it 'increments `discard` in statsd' do
      expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded.invalid")
      subject.process(message)
    end
  end

  context 'with a transaction error' do
    let(:message) { build(:message) }
    before do
      allow(ActiveRecord::Base).to receive(:transaction).and_raise(StandardError)
    end

    it 'increments `discard` in statsd when error is raised' do
      subject.process(message)
      expect(message).to be_discarded
    end

    it 'increments `discard` in statsd when error is raised' do
      expect(GovukStatsd).to receive(:increment).with("monitor.messages.discarded.error")
      subject.process(message)
    end
  end
end
