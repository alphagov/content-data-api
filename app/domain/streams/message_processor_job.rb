require_dependency('streams/messages/factory')

module Streams
  class MessageProcessorJob < ActiveJob::Base
    retry_on ActiveRecord::RecordNotUnique, wait: 5.seconds, attempts: 3

    def perform(payload, routing_key)
      message = Streams::Messages::Factory.build(payload, routing_key)

      if message.invalid?
        Monitor::Messages.increment_discarded
        return
      end

      Monitor::Messages.run(routing_key)

      begin
        ActiveRecord::Base.transaction do
          message.handler.process
        end
      rescue StandardError => e
        GovukError.notify(e)
        logger.error(e.message)
      end
    end

  private

    def logger
      Logger.new(STDERR)
    end
  end
end
