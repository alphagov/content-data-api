class PublishingAPI::PublishingApiBulkImportConsumer
  def process(message)
    # TODO: this is just a stubbed consumer to stop Icinga alerts
    # PublishingApiMessageProcessor.new(message).process
    message.ack
  rescue StandardError => e
    GovukError.notify(e)
    message.discard
  end
end
