class PublishingAPI::BulkImportConsumer
  def process(message)
    do_process(message)

    message.ack
  rescue StandardError => e
    GovukError.notify(e)
    message.discard
  end

  def do_process(message)
    content_item = PublishingAPI::ContentItem.parse(payload: message.payload)
    item = PublishingAPI::ContentItemAdapter.to_dimension_item(
      content_item: content_item,
      payload: message.payload
    )
    item.save!
  end

private

  def current_date
    Time.zone.now.to_date
  end
end
