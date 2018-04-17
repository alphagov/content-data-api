class PublishingApiConsumer
  def process(message)
    PublishingApiMessageProcessor.new(message).process
    message.ack
  rescue StandardError => e
    GovukError.notify(e)
    message.discard
  end
end
