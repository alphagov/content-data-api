module PublishingAPI
  class EventAdapter
    def self.to_dimension_item(event)
      Dimensions::Item.new(
        content_id: event.content_id,
        base_path: event.base_path,
        publishing_api_payload_version: event.payload_version,
        locale: event.locale,
        title: event.title,
        document_type: event.document_type,
        content_purpose_document_supertype: event.content_purpose_document_supertype,
        content_purpose_supergroup: event.content_purpose_supergroup,
        content_purpose_subgroup: event.content_purpose_subgroup,
        first_published_at: event.first_published_at,
        public_updated_at: event.public_updated_at,
        latest: true,
        raw_json: event.payload.to_json
      )
    end
  end
end
