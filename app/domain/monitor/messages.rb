class Monitor::Messages
  def self.run(routing_key)
    new.run(routing_key)
  end

  def run(routing_key)
    statsd_for_messages!(routing_key)
  end

  def self.increment_discarded
    GovukStatsd.increment("monitor.messages.discarded")
  end

private

  def statsd_for_messages!(routing_key)
    GovukStatsd.increment(monitoring_code(routing_key))
  end

  def monitoring_code(routing_key)
    routing_key_type = routing_key.split(".").last
    "monitor.messages.#{routing_key_type}"
  end
end
