module PublishingAPI
  class EventAdapter
    def self.to_dimension_item(event)
      Dimensions::Item.new(
        content_id: event.payload.fetch('content_id'),
        base_path: event.payload.fetch('base_path'),
        publishing_api_payload_version: event.payload.fetch('payload_version'),
        document_type: event.payload.fetch('document_type'),
        locale: event.payload['locale'],
        title: event.payload['title'],
        content_purpose_document_supertype: event.payload['content_purpose_document_supertype'],
        content_purpose_supergroup: event.payload['content_purpose_supergroup'],
        content_purpose_subgroup: event.payload['content_purpose_subgroup'],
        first_published_at: parse_time(event, 'first_published_at'),
        public_updated_at: parse_time(event, 'public_updated_at'),
        latest: true,
        raw_json: event.payload.to_json,
      )
    end

  private

    def self.parse_time(event, attribute_name)
      event.payload.fetch(attribute_name, nil)
    end
  end
end
