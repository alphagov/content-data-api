module PublishingAPI
  class Consumer
    def process(rabbitmq_message)
      message = Messages::Factory.build(rabbitmq_message)

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
  end
end
