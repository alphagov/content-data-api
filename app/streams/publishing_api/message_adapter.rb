module PublishingAPI
  class MessageAdapter
    def initialize(message)
      @message = message
    end

    def content_id
      message.payload["content_id"]
    end

    def locale
      message.payload['locale']
    end

    def new_dimension_items
      if MultipartMessage.is_multipart?(message)
        multipart_message_to_dimension_items
      else
        single_message_to_dimension_item
      end
    end

  private

    attr_reader :message

    def single_message_to_dimension_item
      [
        Dimensions::Item.new(
          base_path: base_path,
          title: title,
          document_text: Etl::Item::Content::Parser.extract_content(message.payload),
          **attributes
        )
      ]
    end

    def multipart_message_to_dimension_items
      multipart_message = MultipartMessage.new(message)
      multipart_message.parts.map.with_index do |part, index|
        Dimensions::Item.new(
          base_path: multipart_message.base_path_for_part(part, index),
          title: multipart_message.title_for(part),
          document_text: Etl::Item::Content::Parser.extract_content(message.payload, subpage_path: part['slug']),
          **attributes
        )
      end
    end

    def attributes
      {
        content_id: content_id,
        publishing_api_payload_version: message.payload.fetch('payload_version'),
        document_type: message.payload.fetch('document_type'),
        locale: locale,
        content_purpose_document_supertype: message.payload['content_purpose_document_supertype'],
        content_purpose_supergroup: message.payload['content_purpose_supergroup'],
        content_purpose_subgroup: message.payload['content_purpose_subgroup'],
        first_published_at: parse_time('first_published_at'),
        primary_organisation_content_id: primary_organisation['content_id'],
        primary_organisation_title: primary_organisation['title'],
        primary_organisation_withdrawn: primary_organisation['withdrawn'],
        public_updated_at: parse_time('public_updated_at'),
        schema_name: message.payload.fetch('schema_name'),
        raw_json: message.payload,
        phase: message.payload.fetch('phase', nil),
        publishing_app: message.payload.fetch('publishing_app', nil),
        rendering_app: message.payload.fetch('rendering_app', nil),
        analytics_identifier: message.payload.fetch('analytics_identifier', nil),
        update_type: message.payload.fetch('update_type', nil),
        expanded_links: message.payload.fetch('expanded_links', nil),
        latest: true
      }
    end

    def base_path
      message.payload.fetch('base_path')
    end

    def primary_organisation
      primary_org = message.payload.dig('expanded_links', 'primary_publishing_organisation') || []
      primary_org.any? ? primary_org[0] : {}
    end

    def title
      message.payload['title']
    end

    def parse_time(attribute_name)
      message.payload.fetch(attribute_name, nil)
    end

    def schema_name
      message.payload.dig('schema_name')
    end
  end
end
