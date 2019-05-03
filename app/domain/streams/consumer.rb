module Streams
  class Consumer
    def process(message)
      routing_key = message.delivery_info.routing_key
      payload = Streams::Payloads::Factory.build(message.payload, routing_key)

      if payload.valid?
        ActiveRecord::Base.transaction { payload.handler.process }

        message.ack
        Monitor::Messages.increment_acknowledged(routing_key)
      else
        message.discard
        Monitor::Messages.increment_discarded('invalid')
      end
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
      Monitor::Messages.increment_discarded('error')
    end
  end
end
