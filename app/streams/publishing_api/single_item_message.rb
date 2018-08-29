module PublishingAPI
  class SingleItemMessage < SimpleDelegator
    def initialize(message)
      super

      @message = message
    end

    def handler
      PublishingAPI::SingleItemHandler
    end

    def invalid?
      mandatory_fields = @message.payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end
  end
end
