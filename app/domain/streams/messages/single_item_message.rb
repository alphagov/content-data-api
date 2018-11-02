module Streams
  class Messages::SingleItemMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def extract_edition_attributes
      [build_attributes(
        base_path: base_path,
        title: title,
        document_text: document_text,
        warehouse_item_id: "#{content_id}:#{locale}"
      )]
    end

    def handler
      Streams::Handlers::SingleItemHandler
    end

  private

    def base_path
      @payload.fetch('base_path')
    end

    def title
      @payload.fetch('title')
    end

    def document_text
      Etl::Edition::Content::Parser.extract_content(@payload)
    end
  end
end
