class PublishingApiConsumer
  def process(message)
    content_id = message.payload['content_id']
    base_path = message.payload['base_path']
    locale = message.payload['locale']

    item = Dimensions::Item.by_natural_key(content_id: content_id, locale: locale)
    if item
      handle_existing(item, base_path, message.delivery_info.routing_key)
    else
      Dimensions::Item.create_empty(content_id: content_id, base_path: base_path, locale: locale)
    end

    message.ack
  end

private


  def handle_existing(item, base_path, routing_key)
    item.outdate! base_path: base_path
    item.gone! if routing_key.include? 'unpublished'
  end
end
