module PublishingAPI
  class Consumer
    def process(message)
      PublishingAPI::MessageHandler.process(message)

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end
  end
end
