module Streams
  class Consumer
    def process(message)
      payload = Streams::Payloads::Factory.build(message.payload, message.delivery_info.routing_key)

      if payload.valid?
        ActiveRecord::Base.transaction { payload.handler.process }

        message.ack
        Monitor::Messages.run(message.delivery_info.routing_key)
      else
        message.discard
        Monitor::Messages.increment_discarded
      end
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
      Monitor::Messages.increment_discarded
    end
  end
end
