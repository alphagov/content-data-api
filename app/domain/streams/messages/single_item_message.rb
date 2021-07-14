module Streams
  class Messages::SingleItemMessage < Messages::BaseMessage
    def edition_attributes
      build_attributes(
        base_path: base_path,
        title: title,
        document_text: document_text,
        warehouse_item_id: "#{content_id}:#{locale}",
      ).merge(
        acronym: acronym,
      )
    end

    def handler
      Streams::Handlers::SingleItemHandler.new(
        edition_attributes,
        @payload,
        @routing_key,
      )
    end

  private

    def base_path
      @payload.fetch("base_path")
    end

    def title
      @payload["title"]
    end

    def document_text
      ::Etl::Edition::Content::Parser.extract_content(@payload)
    end

    def acronym
      acronym = @payload.dig("details", "acronym")
      acronym.presence
    end
  end
end
