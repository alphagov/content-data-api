module Streams
  class Messages::MultipartMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def self.is_multipart?(payload)
      payload.dig('details', 'parts').present?
    end

    def handler
      Streams::Handlers::MultipartHandler
    end

    def extract_edition_attributes
      parts.map.with_index do |part, index|
        base_path = base_path_for_part(part, index)
        build_attributes(
          base_path: base_path,
          title: title_for(part),
          document_text: document_text_for_part(part['slug']),
          warehouse_item_id: "#{content_id}:#{locale}:#{base_path}"
        )
      end
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

  private

    def document_text_for_part(slug)
      Etl::Edition::Content::Parser.extract_content(@payload, subpage_path: slug)
    end
  end
end
