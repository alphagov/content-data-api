class ItemsService
  attr_accessor :client

  def initialize
    self.client = Clients::PublishingAPI.new
  end

  def fetch_all_with_default_locale_only
    client
      .fetch_all(%w[content_id locale user_facing_version])
      .group_by { |content_item| content_item[:content_id] }
      .values
      .map do |content_items_with_the_same_id|
        content_item_with_en_locale_or_first_other(content_items_with_the_same_id)
      end
  end

  def fetch(content_id, locale, version)
    attribute_names = %i[
      public_updated_at
      base_path
      title
      document_type
      description
      content_id
      details
      publishing_app
      locale
    ]
    all_attributes = client.fetch(content_id, locale: locale, version: version)

    Item.new(all_attributes.slice(*attribute_names))
  end

  def links(source_content_id)
    client.links(source_content_id).flat_map do |link_type, content_ids|
      content_ids.map do |target_content_id|
        Link.new(
          source_content_id: source_content_id,
          link_type: link_type,
          target_content_id: target_content_id,
        )
      end
    end
  end

private

  def content_item_with_en_locale_or_first_other(content_items)
    en_content_item = content_items
      .select { |content_item| content_item[:locale] == "en" }
      .first

    en_content_item || content_items.first
  end
end
