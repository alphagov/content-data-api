class Streams::Messages::BaseMessage
  attr_reader :payload

  def initialize(payload)
    @payload = payload
  end

  def build_attributes(base_path:, title: nil, document_text: nil, warehouse_item_id: nil)
    {
      content_id: content_id,
      base_path: base_path,
      title: title,
      publishing_api_payload_version: @payload.fetch('payload_version'),
      document_type: @payload.fetch('document_type'),
      locale: locale,
      content_purpose_document_supertype: @payload['content_purpose_document_supertype'],
      content_purpose_supergroup: @payload['content_purpose_supergroup'],
      content_purpose_subgroup: @payload['content_purpose_subgroup'],
      document_text: document_text,
      first_published_at: parse_time('first_published_at'),
      organisation_id: primary_organisation['content_id'],
      primary_organisation_title: primary_organisation['title'],
      primary_organisation_withdrawn: primary_organisation['withdrawn'],
      public_updated_at: parse_time('public_updated_at'),
      schema_name: @payload.fetch('schema_name'),
      phase: @payload.fetch('phase', nil),
      publishing_app: @payload.fetch('publishing_app', nil),
      rendering_app: @payload.fetch('rendering_app', nil),
      analytics_identifier: @payload.fetch('analytics_identifier', nil),
      update_type: @payload.fetch('update_type', nil),
      latest: false,
      warehouse_item_id: warehouse_item_id,
      withdrawn: withdrawn_notice?,
      historical: historically_political?,
      raw_json: @payload
    }
  end

  def invalid?
    mandatory_fields_nil? || placeholder_schema?
  end

  def withdrawn_notice?
    @payload.dig('withdrawn_notice', :explanation).present?
  end

  def historically_political?
    historical? && political?
  end

  def content_id
    @payload["content_id"]
  end

  def locale
    @payload['locale']
  end

private

  def parse_time(attribute_name)
    @payload.fetch(attribute_name, nil)
  end

  def primary_organisation
    primary_org = @payload.dig('expanded_links', 'primary_publishing_organisation') || []
    primary_org.any? ? primary_org[0] : {}
  end

  def political?
    @payload.dig('details', 'political') || false
  end

  def historical?
    @payload.dig('details', 'government').present? && !@payload.dig('details', 'government', 'current')
  end

  def mandatory_fields_nil?
    mandatory_fields = @payload.values_at('base_path', 'schema_name')
    mandatory_fields.any?(&:nil?)
  end

  def placeholder_schema?
    @payload['schema_name'].include?('placeholder')
  end
end
