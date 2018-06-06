class PublishingAPI::ContentItem
  include ActiveModel::Model

  attr_accessor :base_path
  attr_accessor :content_id
  attr_accessor :content_purpose_document_supertype
  attr_accessor :content_purpose_subgroup
  attr_accessor :content_purpose_supergroup
  attr_accessor :details
  attr_accessor :document_type
  attr_accessor :first_published_at
  attr_accessor :links
  attr_accessor :locale
  attr_accessor :payload_version
  attr_accessor :public_updated_at
  attr_accessor :title


  def self.parse_message(message_payload)
    new(
      base_path: message_payload.fetch('base_path'),
      content_id: message_payload.fetch('content_id'),
      content_purpose_document_supertype: message_payload['content_purpose_document_supertype'],
      content_purpose_subgroup: message_payload['content_purpose_subgroup'],
      content_purpose_supergroup: message_payload['content_purpose_supergroup'],
      details: message_payload.fetch('details'),
      document_type: message_payload['document_type'],
      first_published_at: message_payload['first_published_at'],
      links: message_payload.fetch('expanded_links'),
      locale: message_payload['locale'] || 'en',
      payload_version: message_payload.fetch('payload_version'),
      public_updated_at: message_payload['public_updated_at'],
      title: message_payload['title']
    )
  end

private

  def current_date
    Time.zone.now.to_date
  end
end
