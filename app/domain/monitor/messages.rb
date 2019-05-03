class Monitor::Messages
  def self.increment_discarded(reason)
    GovukStatsd.increment("monitor.messages.discarded.#{reason}")
  end

  def self.increment_retried(reason)
    GovukStatsd.increment("monitor.messages.retried.#{reason}")
  end

  def self.increment_acknowledged(routing_key)
    GovukStatsd.increment(monitoring_code(routing_key))
  end

  def self.monitoring_code(routing_key)
    routing_key_type = routing_key.split('.').last
    "monitor.messages.acknowledged.#{routing_key_type}"
  end
end
