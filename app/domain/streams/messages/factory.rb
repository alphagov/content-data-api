module Streams::Messages
  class Factory
    def self.build(payload)
      if RedirectMessage.is_redirect?(payload)
        RedirectMessage.new(payload)
      elsif MultipartMessage.is_multipart?(payload)
        MultipartMessage.new(payload)
      else
        SingleItemMessage.new(payload)
      end
    end
  end
end
