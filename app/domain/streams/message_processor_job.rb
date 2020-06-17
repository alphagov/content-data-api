require_dependency("streams/messages/factory")

module Streams
  class MessageProcessorJob < ActiveJob::Base # rubocop:disable Rails/ApplicationJob
    retry_on ActiveRecord::RecordNotUnique, wait: 5.seconds, attempts: 3

    def perform(payload, routing_key)
      message = Streams::Messages::Factory.build(payload, routing_key)

      if message.invalid?
        Monitor::Messages.increment_discarded
        return
      end

      Monitor::Messages.run(routing_key)

      ActiveRecord::Base.transaction do
        message.handler.process
      end
    end
  end
end
