module PublishingAPI
  class Messages::MultipartMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def self.is_multipart?(payload)
      payload.dig('details', 'parts').present?
    end

    def handler
      PublishingAPI::Handlers::MultipartHandler
    end

    def parts
      message_parts = @payload.dig('details', 'parts').dup
      if doc_type == 'travel_advice'
        message_parts.prepend(
          'slug' => base_path,
          'title' => 'Summary',
          'body' => [@payload.dig('details', 'summary').find { |x| x['content_type'] == "text/html" }]
        )
      end
      message_parts
    end

    def title_for(part)
      "#{main_title}: #{part.fetch('title')}"
    end

    def base_path_for_part(part, index)
      slug = part.fetch('slug')
      return base_path if index.zero?

      "#{base_path}/#{slug}"
    end

    attr_reader :payload, :message_parts

    def doc_type
      @payload.fetch('document_type')
    end

    def base_path
      @payload.fetch('base_path')
    end

    def main_title
      @payload.fetch('title')
    end
  end
end
