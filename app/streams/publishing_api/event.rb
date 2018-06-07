# https://github.com/alphagov/publishing-api/blob/master/doc/rabbitmq.md#event_type
class PublishingAPI::Event
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
  attr_accessor :payload
  attr_accessor :payload_version
  attr_accessor :routing_key
  attr_accessor :public_updated_at
  attr_accessor :title


  def self.parse(message)
    payload = message.payload
    routing_key = message.delivery_info.routing_key

    new(
      base_path: payload.fetch('base_path'),
      content_id: payload.fetch('content_id'),
      content_purpose_document_supertype: payload['content_purpose_document_supertype'],
      content_purpose_subgroup: payload['content_purpose_subgroup'],
      content_purpose_supergroup: payload['content_purpose_supergroup'],
      details: payload.fetch('details'),
      document_type: payload['document_type'],
      first_published_at: Time.parse(payload['first_published_at']),
      links: payload.fetch('expanded_links'),
      locale: payload['locale'] || 'en',
      payload: payload,
      payload_version: payload.fetch('payload_version'),
      routing_key: routing_key,
      public_updated_at: Time.parse(payload['public_updated_at']),
      title: payload['title']
    )
  end
end


