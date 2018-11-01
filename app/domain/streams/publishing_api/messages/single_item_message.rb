module Streams::PublishingAPI
  class Messages::SingleItemMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def handler
      Streams::PublishingAPI::Handlers::SingleItemHandler
    end
  end
end
