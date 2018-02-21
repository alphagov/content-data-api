class PublishingApiConsumer
  def process(message)
    message.ack
    p "message received : #{message.payload}"
  end
end
