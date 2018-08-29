module PublishingAPI
  class Messages::SingleItemMessage < SimpleDelegator
    include Messages::Concerns::MessageValidation

    def initialize(message)
      super

      @message = message
    end

    def handler
      PublishingAPI::Handlers::SingleItemHandler
    end

    def invalid?
      mandatory_fields = @message.payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end
  end
end
