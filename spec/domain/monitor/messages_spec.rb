RSpec.describe Monitor::Messages do
  describe '.increment discarded' do
    it 'increments the appropiate Statsd key' do
      expect(GovukStatsd).to receive(:increment).with('monitor.messages.reject.reason')
      Monitor::Messages.increment_discarded('reason')
    end
  end

  describe '.increment retried' do
    it 'increments the appropiate Statsd key' do
      expect(GovukStatsd).to receive(:increment).with('monitor.messages.requeue.reason')
      Monitor::Messages.increment_retried('reason')
    end
  end

  describe '.increment acknowledged' do
    it 'increments the appropiate Statsd key' do
      expect(GovukStatsd).to receive(:increment).with('monitor.messages.ack.reason')
      Monitor::Messages.increment_acknowledged('reason')
    end
  end
end
