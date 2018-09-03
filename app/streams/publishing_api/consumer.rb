module PublishingAPI
  class Consumer
    def process(rabbitmq_message)
      message = MessageFactory.build(rabbitmq_message)

      do_process(message)

      rabbitmq_message.ack
    rescue StandardError => e
      GovukError.notify(e)
      rabbitmq_message.discard
    end

  private

    def do_process(message)
      return if message.invalid? || message.is_old_message?

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
      end
    end

    class MessageFactory
      def self.build(rabbitmq_message)
        payload = rabbitmq_message.payload

        if PublishingAPI::Messages::MultipartMessage.is_multipart?(rabbitmq_message)
          PublishingAPI::Messages::MultipartMessage.new(payload)
        else
          PublishingAPI::Messages::SingleItemMessage.new(payload)
        end
      end
    end
  end
end
