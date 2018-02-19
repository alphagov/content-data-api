class PublishingApiConsumer
  def process(message)
    content_id = message.payload['content_id']
    base_path = message.payload['base_path']

    item = Dimensions::Item.find_by(content_id: content_id, latest: true)
    if item
      item.dirty!
    else
      Dimensions::Item.create_empty(content_id, base_path)
    end

    message.ack
  end
end
