module PublishingAPI
  class Messages::MultipartMessage < SimpleDelegator
    def initialize(message)
      super

      @message = message
    end

    def self.is_multipart?(message)
      message.payload.dig('details', 'parts').present?
    end

    def handler
      PublishingAPI::Handlers::MultipartHandler
    end

    def invalid?
      mandatory_fields = @message.payload.values_at('base_path', 'schema_name')
      mandatory_fields.any?(&:nil?)
    end

    def parts
      message_parts = message.payload.dig('details', 'parts').dup
      if doc_type == 'travel_advice'
        message_parts.prepend(
          'slug' => base_path,
          'title' => 'Summary',
          'body' => [message.payload.dig('details', 'summary').find { |x| x['content_type'] == "text/html" }]
        )
      end
      message_parts
    end

    def title_for(part)
      part.fetch('title')
    end

    def base_path_for_part(part, index)
      slug = part.fetch('slug')
      return base_path if index.zero?

      "#{base_path}/#{slug}"
    end

  private

    attr_reader :message, :message_parts

    def doc_type
      message.payload.fetch('document_type')
    end

    def base_path
      message.payload.fetch('base_path')
    end
  end
end
