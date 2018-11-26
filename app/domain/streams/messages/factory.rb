module Streams::Messages
  class Factory
    def self.build(payload, routing_key)
      if MultipartMessage.is_multipart?(payload)
        MultipartMessage.new(payload, routing_key)
      else
        SingleItemMessage.new(payload, routing_key)
      end
    end
  end
end
