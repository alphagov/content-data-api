module Streams::Payloads
  class Factory
    def self.build(payload, routing_key)
      if MultipartPayload.is_multipart?(payload)
        MultipartPayload.new(payload, routing_key)
      else
        SingleItemPayload.new(payload, routing_key)
      end
    end
  end
end
