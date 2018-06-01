class PublishingAPI::PublishingApiConsumer
  def process(message)
    PublishingAPI::PublishingApiMessageProcessor.new(message).process
    message.ack
  rescue StandardError => e
    GovukError.notify(e)
    message.discard
  end
end
