module PublishingAPI
  class MessageAdapter
    attr_reader :items

    def self.to_dimension_items(*args)
      new(*args).to_dimension_items
    end

    def initialize(message)
      @message = message
      @items = []
    end

    def to_dimension_item(item_message)
      Dimensions::Item.new(
        content_id: item_message.payload.fetch('content_id'),
        base_path: item_message.payload.fetch('base_path'),
        publishing_api_payload_version: item_message.payload.fetch('payload_version'),
        document_type: item_message.payload.fetch('document_type'),
        locale: item_message.payload['locale'],
        title: item_message.payload['title'],
        content_purpose_document_supertype: item_message.payload['content_purpose_document_supertype'],
        content_purpose_supergroup: item_message.payload['content_purpose_supergroup'],
        content_purpose_subgroup: item_message.payload['content_purpose_subgroup'],
        first_published_at: parse_time('first_published_at'),
        primary_organisation_content_id: primary_organisation['content_id'],
        primary_organisation_title: primary_organisation['title'],
        primary_organisation_withdrawn: primary_organisation['withdrawn'],
        public_updated_at: parse_time('public_updated_at'),
        schema_name: item_message.payload.fetch('schema_name'),
        latest: true,
        raw_json: item_message.payload,
        content: Item::Content::Parser.extract_content(item_message.payload)
      )
    end

    def to_dimension_items
      if has_multiple_parts?
        parts.each do |part|
          @items << Dimensions::Item.new(
            base_path: base_path_for_part(part),
            content_id: message.payload.fetch('content_id'),
            publishing_api_payload_version: message.payload.fetch('payload_version'),
            document_type: message.payload.fetch('document_type'),
            locale: message.payload['locale'],
            title: title_for_part(part),
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
            raw_json: message.payload,
            content: Item::Content::Parser.extract_content(message.payload, subpage: part['slug'])
          )
        end
      else
        @items << to_dimension_item(message)
      end

      items
    end

    def subpages_by_base_path
      return {} unless has_multiple_parts?

      parts.map { |part| [base_path_for_part(part), part.fetch('slug')] }.to_h
    end

    def has_multiple_parts?
      parts.present?
    end

    def primary_organisation
      primary_org = message.payload.dig('expanded_links', 'primary_publishing_organisation') || []
      primary_org.any? ? primary_org[0] : {}
    end

  private

    attr_reader :message

    def base_path
      message.payload.fetch('base_path')
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
