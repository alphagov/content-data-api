module PublishingAPI
  class MultipartMessage
    def self.is_multipart?(message)
      message.payload.dig('details', 'parts').present?
    end

    def initialize(message)
      @message = message
    end

    def parts
      message_parts = message.payload.dig('details', 'parts')

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
