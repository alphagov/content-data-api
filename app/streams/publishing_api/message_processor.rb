class PublishingAPI::MessageProcessor
  def initialize(message)
    @incoming_content_item = PublishingAPI::ContentItem.parse(payload: message.payload)
    @routing_key = message.delivery_info.routing_key
  end

  def process
    item = Dimensions::Item.by_natural_key(content_id: incoming_content_item.content_id, locale: incoming_content_item.locale)

    if item
      existing_payload_version = item.publishing_api_payload_version

      if incoming_content_item.payload_version > existing_payload_version
        handle_existing(item)
      else
        # Skip out of date and repeated messages from the publishing API.
        # This is to ensure that our "latest" record is actually the latest.
        #
        # RabbitMQ guarantees at-least-once delivery when using acknowledgements,
        # so messages can be duplicated, plus we can't guarantee the order of
        # processing because we can have multiple consumers working in parallel.
        logger.info "Skipping message from publishing API: published with #{incoming_content_item.payload_version} but we've already received a message with #{item.publishing_api_payload_version}"
      end
    else
      Dimensions::Item.create_empty(
        content_id: incoming_content_item.content_id,
        base_path: incoming_content_item.base_path,
        locale: incoming_content_item.locale,
        payload_version: incoming_content_item.payload_version
      )
    end
  end

private

  attr_reader :incoming_content_item
  attr_reader :routing_key

  def handle_existing(item)
    case routing_key
    when /major|minor/
      handle_new_version(item)
    when /unpublish/
      handle_unpublish(item)
    else
      handle_existing_version(item)
    end
  end

  def handle_new_version(item)
    new_item = item.copy_to_new_version!(base_path: incoming_content_item.base_path, payload_version: incoming_content_item.payload_version)

    Items::Importers::ContentDetails.run(new_item.id, current_date.day, current_date.month, current_date.year)
  end

  def handle_unpublish(item)
    new_item = item.copy_to_new_version!(base_path: incoming_content_item.base_path, payload_version: incoming_content_item.payload_version)
    new_item.gone!
  end

  def handle_existing_version(item)
    Items::Importers::ContentDetails.run(item.id, current_date.day, current_date.month, current_date.year)
  end

  def current_date
    Time.zone.now.to_date
  end
end
