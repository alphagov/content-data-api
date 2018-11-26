module Streams
  class Messages::SingleItemMessage < Messages::BaseMessage
    def initialize(payload, routing_key)
      super(payload, routing_key)
    end

    def extract_edition_attributes
      build_attributes(
        base_path: base_path,
        title: title,
        document_text: document_text,
        warehouse_item_id: "#{content_id}:#{locale}"
      )
    end

    def handler
      Streams::Handlers::SingleItemHandler.new(extract_edition_attributes)
    end

  private

    def base_path
      @payload.fetch('base_path')
    end

    def title
      @payload['title']
    end

    def document_text
      ::Etl::Edition::Content::Parser.extract_content(@payload)
    end
  end
end
