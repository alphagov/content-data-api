class Streams::Handlers::BaseHandler
  def update_editions(items_with_old_editions)
    items_to_grow = items_with_old_editions.keep_if do |hsh|
      Streams::GrowDimension.should_grow? old_edition: hsh[:old_edition], attrs: hsh[:attrs]
    end
    items_to_grow.each(&method(:update_edition))
  end

private

  def update_edition(hash)
    new_edition = Dimensions::Edition.new(hash[:attrs])
    new_edition.facts_edition = Etl::Edition::Processor.process(hash[:old_edition], new_edition)
    new_edition.promote!(hash[:old_edition])
  end

  def find_old_edition(attrs)
    { attrs: attrs, old_edition: Dimensions::Edition.find_by(content_id: attrs[:content_id], locale: attrs[:locale], latest: true) }
  end

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
      organisation_id: primary_organisation['content_id'],
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
      withdrawn: message.withdrawn_notice?,
      historical: message.historically_political?,
      raw_json: message.payload
    }
  end

  def update_required?(old_edition:, base_path:, title:, document_text:)
    return true unless old_edition
    old_edition.change_from?(comparable_attributes(base_path, title, document_text))
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

  def excluded_from_comparison?(key, _value)
    %i[publishing_api_payload_version public_updated_at id update_at created_at latest].include? key
  end
end
