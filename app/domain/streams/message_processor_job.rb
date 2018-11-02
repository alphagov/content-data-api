module Streams
  class MessageProcessorJob < ActiveJob::Base
    retry_on ActiveRecord::RecordNotUnique, wait: 5.seconds, attempts: 3

    def perform(payload, routing_key)
      message = Messages::Factory.build(payload)

      if message.invalid? || message.is_old_message?
        Monitor::Messages.increment_discarded
        return
      end

      Monitor::Messages.run(routing_key)

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
      end
    end
  end
end
