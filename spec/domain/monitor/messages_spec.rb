RSpec.describe Monitor::Messages do
  describe '.increment discarded' do
    it 'increments the appropiate Statsd key' do
      expect(GovukStatsd).to receive(:increment).with('monitor.messages.discarded.reason')
      Monitor::Messages.increment_discarded('reason')
    end
  end

  describe '.increment retried' do
    it 'increments the appropiate Statsd key' do
      expect(GovukStatsd).to receive(:increment).with('monitor.messages.retried.reason')
      Monitor::Messages.increment_retried('reason')
    end
  end

  describe '.increment acknowledged' do
    it 'increments the appropiate Statsd key' do
      expect(GovukStatsd).to receive(:increment).with('monitor.messages.acknowledged.event_type')
      Monitor::Messages.increment_acknowledged('document_type.event_type')
    end
  end
end
