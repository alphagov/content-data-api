class PublishingApiConsumer
  def process(message)
    content_id = message.payload['content_id']
    base_path = message.payload['base_path']
    locale = message.payload['locale']

    item = Dimensions::Item.by_natural_key(content_id: content_id, locale: locale).first
    if item
      handle_existing(item, message.delivery_info.routing_key)
    else
      Dimensions::Item.create_empty(content_id: content_id, base_path: base_path, locale: locale)
    end

    message.ack
  end

private

  def handle_existing(item, routing_key)
    item.outdate!
    item.gone! if routing_key.include? 'unpublished'
  end
end
