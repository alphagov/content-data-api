module PublishingAPI
  class Consumer
    def process(message)
      do_process(message)
      message.ack
    rescue StandardError => e
      GovukError.notify(e)
      message.discard
    end

    def do_process(message); end
  end
end
