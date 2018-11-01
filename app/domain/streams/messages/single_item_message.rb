module Streams
  class Messages::SingleItemMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def handler
      Streams::Handlers::SingleItemHandler
    end
  end
end
