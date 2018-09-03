module PublishingAPI::Messages
  class Factory
    def self.build(rabbitmq_message)
      payload = rabbitmq_message.payload

      if MultipartMessage.is_multipart?(rabbitmq_message)
        MultipartMessage.new(payload)
      else
        SingleItemMessage.new(payload)
      end
    end
  end
end
