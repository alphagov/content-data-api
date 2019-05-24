class Monitor::Messages
  def self.increment_discarded(reason)
    GovukStatsd.increment("monitor.messages.reject.#{reason}")
  end

  def self.increment_retried(reason)
    GovukStatsd.increment("monitor.messages.requeue.#{reason}")
  end

  def self.increment_acknowledged(reason)
    GovukStatsd.increment("monitor.messages.ack.#{reason}")
  end
end
