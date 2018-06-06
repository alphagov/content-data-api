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


  def self.parse(payload: )
    new(
      base_path: payload.fetch('base_path'),
      content_id: payload.fetch('content_id'),
      content_purpose_document_supertype: payload['content_purpose_document_supertype'],
      content_purpose_subgroup: payload['content_purpose_subgroup'],
      content_purpose_supergroup: payload['content_purpose_supergroup'],
      details: payload.fetch('details'),
      document_type: payload['document_type'],
      first_published_at: payload['first_published_at'],
      links: payload.fetch('expanded_links'),
      locale: payload['locale'] || 'en',
      payload_version: payload.fetch('payload_version'),
      public_updated_at: payload['public_updated_at'],
      title: payload['title']
    )
  end

private

  def current_date
    Time.zone.now.to_date
  end
end
