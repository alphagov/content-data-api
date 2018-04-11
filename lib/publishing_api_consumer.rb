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
    # If we have an event to update the basepath, in order to get the latest
    # version from from the content store we need to have the latest path
    item.update! base_path: base_path

    item.outdate!
    item.gone! if routing_key.include? 'unpublished'
  end
end
