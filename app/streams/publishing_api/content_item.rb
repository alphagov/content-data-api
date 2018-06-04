class PublishingAPI::ContentItem
  attr_reader :content_id
  attr_reader :base_path
  attr_reader :payload_version
  attr_reader :locale
  attr_reader :metadata
  attr_reader :details
  attr_reader :links

  def self.parse_message(message_payload)
    content_id = message_payload.fetch('content_id')
    base_path = message_payload.fetch('base_path')
    payload_version = message_payload.fetch('payload_version')
    locale = message_payload['locale'] || 'en'
    metadata = Item::Metadata::Parsers::Metadata.parse(message_payload)
    details = message_payload.fetch('details')
    links = message_payload.fetch('expanded_links')

    new(
      content_id: content_id,
      base_path: base_path,
      payload_version: payload_version,
      locale: locale,
      links: links,
      details: details,
      metadata: metadata,
    )
  end

  def initialize(content_id:, base_path:, payload_version:, locale:, links:, details:, metadata:)
    @content_id = content_id
    @base_path = base_path
    @payload_version = payload_version
    @locale = locale
    @links = links
    @details = details
    @metadata = metadata
  end

private

  def current_date
    Time.zone.now.to_date
  end
end
