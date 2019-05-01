require_dependency('streams/payloads/factory')

module Streams
  class MessageProcessorJob < ActiveJob::Base
    retry_on ActiveRecord::RecordNotUnique, wait: 5.seconds, attempts: 3

    def perform(raw_payload, routing_key)
      payload = Streams::Payloads::Factory.build(raw_payload, routing_key)

      if payload.valid?
        Monitor::Messages.run(routing_key)

        ActiveRecord::Base.transaction do
          payload.handler.process
        end
      else
        Monitor::Messages.increment_discarded
      end
    end
  end
end
