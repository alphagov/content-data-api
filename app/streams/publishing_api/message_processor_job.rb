module PublishingAPI
  class MessageProcessorJob
    def self.perform_later(payload)
      message = Messages::Factory.build(payload)
      return if message.invalid? || message.is_old_message?

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
      end
    end
  end
end
