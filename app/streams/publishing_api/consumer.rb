module PublishingAPI
  class Consumer
    def process(message)
      MessageProcessor.new(message).process
      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end
  end
end
