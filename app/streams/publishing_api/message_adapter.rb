module PublishingAPI
  class MessageAdapter
    def self.to_dimension_item(*args)
      new(*args).to_dimension_item
    end

    def initialize(message)
      @message = message
    end

    def to_dimension_item
      Dimensions::Item.new(
        content_id: message.payload.fetch('content_id'),
        base_path: message.payload.fetch('base_path'),
        publishing_api_payload_version: message.payload.fetch('payload_version'),
        document_type: message.payload.fetch('document_type'),
        locale: message.payload['locale'],
        title: message.payload['title'],
        content_purpose_document_supertype: message.payload['content_purpose_document_supertype'],
        content_purpose_supergroup: message.payload['content_purpose_supergroup'],
        content_purpose_subgroup: message.payload['content_purpose_subgroup'],
        first_published_at: parse_time('first_published_at'),
        primary_organisation_content_id: primary_organisation['content_id'],
        primary_organisation_title: primary_organisation['title'],
        primary_organisation_withdrawn: primary_organisation['withdrawn'],
        public_updated_at: parse_time('public_updated_at'),
        schema_name: message.payload.fetch('schema_name'),
        latest: true,
        raw_json: message.payload.to_json,
      )
    end

    def primary_organisation
      primary_org = message.payload.dig('expanded_links', 'primary_publishing_organisation') || []
      primary_org.any? ? primary_org[0] : {}
    end

  private

    attr_reader :message

    def parse_time(attribute_name)
      message.payload.fetch(attribute_name, nil)
    end
  end
end
