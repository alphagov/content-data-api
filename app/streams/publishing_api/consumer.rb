module PublishingAPI
  class Consumer
    def process(message)
      if is_invalid_message?(message)
        GovukError.notify(StandardError.new, extra: { payload: message.payload })
        message.discard
        return
      end

      PublishingAPI::MessageHandler.process(message)

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

  private

    def is_invalid_message?(message)
      !message.payload['base_path'].present?
    end
  end
end
