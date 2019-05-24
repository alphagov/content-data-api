module Streams
  class Consumer
    def process(message)
      routing_key = message.delivery_info.routing_key
      payload = Streams::Payloads::Factory.build(message.payload, routing_key)

      if payload.valid?
        ActiveRecord::Base.transaction { payload.handler.process }

        message.ack
        Monitor::Messages.increment_acknowledged('successfully_processed')
      else
        message.ack
        Monitor::Messages.increment_acknowledged('invalid_payload')
      end
    rescue StandardError => e
      GovukError.notify(e)
      if message.delivery_info.redelivered?
        message.discard
        Monitor::Messages.increment_discarded('error')
      else
        sleep(1)
        message.retry
        Monitor::Messages.increment_retried('error')
      end
    end
  end
end
