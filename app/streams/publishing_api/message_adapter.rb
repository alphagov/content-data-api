module PublishingAPI
  class MessageAdapter
    def initialize(message)
      @message = message
    end

    def existing_dimension_items
      Dimensions::Item.existing_latest_items(
        content_id,
        new_dimension_items.map(&:base_path)
      )
    end

    def new_dimension_items
      if has_multiple_parts?
        parts.map do |part|
          Dimensions::Item.new(
            base_path: base_path_for_part(part),
            title: title_for_part(part),
            content: Item::Content::Parser.extract_content(message.payload, subpage: part['slug']),
            **attributes
          )
        end
      else
        [
          Dimensions::Item.new(
            base_path: base_path,
            title: title,
            content: Item::Content::Parser.extract_content(message.payload),
            **attributes
          )
        ]
      end
    end

  private

    attr_reader :message

    def attributes
      {
        content_id: content_id,
        publishing_api_payload_version: message.payload.fetch('payload_version'),
        document_type: message.payload.fetch('document_type'),
        locale: message.payload['locale'],
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
        latest: true
      }
    end

    def primary_organisation
      primary_org = message.payload.dig('expanded_links', 'primary_publishing_organisation') || []
      primary_org.any? ? primary_org[0] : {}
    end

    def has_multiple_parts?
      parts.present?
    end

    def content_id
      message.payload["content_id"]
    end

    def base_path
      message.payload.fetch('base_path')
    end

    def title
      message.payload['title']
    end

    def base_path_for_part(part)
      slug = part.fetch('slug')
      base_path + '/' + slug
    end

    def title_for_part(part)
      part.fetch('title')
    end

    def parse_time(attribute_name)
      message.payload.fetch(attribute_name, nil)
    end

    def parts
      message.payload.dig('details', 'parts')
    end
  end
end
