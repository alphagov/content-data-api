class PublishingAPI::BaseHandler
  def all_attributes
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
      phase: message.payload.fetch('phase', nil),
      publishing_app: message.payload.fetch('publishing_app', nil),
      rendering_app: message.payload.fetch('rendering_app', nil),
      analytics_identifier: message.payload.fetch('analytics_identifier', nil),
      update_type: message.payload.fetch('update_type', nil),
      latest: true,
      raw_json: message.payload
    }
  end

  def update_required?(old_item:, base_path:, title:, document_text:)
    return true unless old_item
    old_item.updated_by?(comparable_attributes(base_path, title, document_text))
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

  def content_id
    message.payload["content_id"]
  end

  def locale
    message.payload['locale']
  end

  def parse_time(attribute_name)
    message.payload.fetch(attribute_name, nil)
  end

  def comparable_attributes(base_path, title, document_text)
    all_attributes.reject(&method(:excluded_from_comparison?)).merge(
      base_path: base_path,
      title: title,
      document_text: document_text
    )
  end

  def excluded_from_comparison?(key, _)
    %i[publishing_api_payload_version public_updated_at id update_at created_at latest].include? key
  end
  # rubocop:enable Metrics/BlockLength
end
