class PublishingApiConsumer
  def process(message)
    process_message(message)

    message.ack
  rescue StandardError => e
    GovukError.notify(e)
    message.discard
  end

private

  def process_message(message)
    content_id = message.payload['content_id']
    base_path = message.payload['base_path']
    locale = message.payload['locale'] || 'en'

    item = Dimensions::Item.by_natural_key(content_id: content_id, locale: locale)
    if item
      handle_existing(item, base_path, message.delivery_info.routing_key)
    else
      Dimensions::Item.create_empty(content_id: content_id, base_path: base_path, locale: locale)
    end
  end

  def handle_existing(item, base_path, routing_key)
    case routing_key
    when /major|minor/
      item.copy_to_new_outdated_version!(base_path)
    when /unpublished/
      new_item = item.copy_to_new_outdated_version!(base_path)
      new_item.gone!
    else
      # If we get a links update, or an item is republished for technical reasons,
      # don't store a new version, but update the outdated time on the previous one.
      item.outdate!
    end
  end
end
