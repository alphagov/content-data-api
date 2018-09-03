module PublishingAPI
  class Consumer
    def process(message)
      MessageProcessorJob.perform_later(message.payload)

      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end
  end
end
