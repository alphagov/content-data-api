module Streams
  class Consumer
    def process(message)
      Streams::MessageProcessorJob.perform_later(message.payload, message.delivery_info.routing_key)
      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
      Monitor::Messages.increment_discarded
    end
  end
end
