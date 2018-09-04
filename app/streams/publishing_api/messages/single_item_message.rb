module PublishingAPI
  class Messages::SingleItemMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def handler
      PublishingAPI::Handlers::SingleItemHandler
    end

    def invalid?
      mandatory_fields = @payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end
  end
end
