module Streams::PublishingAPI::Messages
  class Factory
    def self.build(payload)
      if MultipartMessage.is_multipart?(payload)
        MultipartMessage.new(payload)
      else
        SingleItemMessage.new(payload)
      end
    end
  end
end
