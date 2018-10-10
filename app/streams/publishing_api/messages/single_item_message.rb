module PublishingAPI
  class Messages::SingleItemMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def handler
      PublishingAPI::Handlers::SingleItemHandler
    end
  end
end
