class PublishingApiConsumer
  def process(message)
    content_id = message.payload['content_id']
    base_path = message.payload['base_path']

    item = Dimensions::Item.find_by(content_id: content_id, latest: true)
    if item
      handle_existing(item, message.delivery_info.routing_key)
    else
      Dimensions::Item.create_empty(content_id, base_path)
    end

    message.ack
  end

private

  def handle_existing(item, routing_key)
    item.outdated!
    item.gone! if routing_key.include? 'unpublished'
  end
end
