module PublishingAPI
  class Consumer
    def process(message)
      do_process(message.payload)

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def do_process(payload)
      message = Messages::Factory.build(payload)
      return if message.invalid? || message.is_old_message?

      ActiveRecord::Base.transaction do
        handler = message.handler

        handler.process(message)
      end
    end
  end
end
