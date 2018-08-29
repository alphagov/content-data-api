module PublishingAPI
  class Consumer
    def process(rabbit_mq_message)
      message = MessageFactory.build(rabbit_mq_message)

      if message.invalid?
        message.discard
      else
        do_process(message)
      end
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def do_process(message)
      return if PublishingAPI::MessageValidator.is_old_message?(message)

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
        message.ack
      end
    end

    class MessageFactory
      def self.build(rabbitmq_message)
        if PublishingAPI::Messages::MultipartMessage.is_multipart?(rabbitmq_message)
          PublishingAPI::Messages::MultipartMessage.new(rabbitmq_message)
        else
          PublishingAPI::Messages::SingleItemMessage.new(rabbitmq_message)
        end
      end
    end
  end
end
