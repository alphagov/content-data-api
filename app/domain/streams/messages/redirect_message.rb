module Streams
  class Messages::RedirectMessage < Messages::BaseMessage
    def initialize(payload)
      super
    end

    def extract_edition_attributes
      build_attributes(
        base_path: base_path,
        warehouse_item_id: content_id.to_s
      )
    end

    def self.is_redirect?(payload)
      payload['document_type'] == 'redirect'
    end

    def handler
      Streams::Handlers::RedirectHandler.new(extract_edition_attributes)
    end

  private

    def base_path
      @payload['base_path']
    end

    def title
      "Redirect to: #{base_path}"
    end
  end
end
