module PublishingAPI
  class MessageAdapter
    attr_reader :doc_type

    def initialize(message)
      @message = message
      @doc_type = message.payload.fetch('document_type')
    end

    def content_id
      message.payload["content_id"]
    end

    def locale
      message.payload['locale']
    end

    def new_dimension_items
      if has_multiple_parts?
        add_summary_part if doc_type == 'travel_advice'
        parts.each_with_index.map do |part, index|
          Dimensions::Item.new(
            base_path: base_path_for_part(part, index),
            title: title_for_part(part),
            document_text: Etl::Item::Content::Parser.extract_content(message.payload, subpage: part['slug']),
            **attributes
          )
        end
      else
        [
          Dimensions::Item.new(
            base_path: base_path,
            title: title,
            document_text: Etl::Item::Content::Parser.extract_content(message.payload),
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

    def base_path
      message.payload.fetch('base_path')
    end

    def title
      message.payload['title']
    end

    def base_path_for_part(part, index)
      slug = part.fetch('slug')

      index.zero? ? base_path : base_path + '/' + slug
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

    def add_summary_part
      parts.prepend(
        'slug' => '',
        'title' => 'Summary',
        'body' => [message.payload.dig('details', 'summary').find { |x| x['content_type'] == "text/html" }]
      )
    end

    def schema_name
      message.payload.dig('schema_name')
    end
  end
end
