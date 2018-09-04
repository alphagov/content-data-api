module PublishingAPI
  class MessageProcessorJob < ActiveJob::Base
    def perform(payload)
      message = Messages::Factory.build(payload)
      return if message.invalid? || message.is_old_message?

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
      end
    end
  end
end
