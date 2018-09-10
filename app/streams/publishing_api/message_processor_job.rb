module PublishingAPI
  class MessageProcessorJob < ActiveJob::Base
    def perform(payload)
      message = Messages::Factory.build(payload)

      if message.invalid? || message.is_old_message?
        Monitor::Messages.increment_discarded
        return
      end

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
      end
    end
  end
end
