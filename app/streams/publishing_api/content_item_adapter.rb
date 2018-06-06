module PublishingAPI
  class ContentItemAdapter
    def self.to_dimension_item(content_item:, payload:)
      Dimensions::Item.new(
        content_id: content_item.content_id,
        base_path: content_item.base_path,
        publishing_api_payload_version: content_item.payload_version,
        locale: content_item.locale,
        title: content_item.title,
        document_type: content_item.document_type,
        content_purpose_document_supertype: content_item.content_purpose_document_supertype,
        content_purpose_supergroup: content_item.content_purpose_supergroup,
        content_purpose_subgroup: content_item.content_purpose_subgroup,
        first_published_at: content_item.first_published_at,
        public_updated_at: content_item.public_updated_at,
        latest: true,
        raw_json: payload.to_json
      )
    end
  end
end
