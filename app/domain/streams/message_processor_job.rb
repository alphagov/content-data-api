require_dependency('streams/messages/factory')

module Streams
  class MessageProcessorJob < ActiveJob::Base
    retry_on ActiveRecord::RecordNotUnique, wait: 5.seconds, attempts: 3

    def perform(payload, routing_key)
      message = Streams::Messages::Factory.build(payload, routing_key)

      if message.valid?
        Monitor::Messages.run(routing_key)

        ActiveRecord::Base.transaction do
          message.handler.process
        end
      else
        Monitor::Messages.increment_discarded
      end
    end
  end
end
